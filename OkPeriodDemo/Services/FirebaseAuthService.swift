//
//  FirebaseAuthService.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import FirebaseAuth
import Foundation

final class FirebaseAuthService: AuthServiceProtocol {
    private let otpManager: OTPManager
    private let sessionManager: SessionManaging
    private let keychain = EmailPasswordKeychain()

    init(
        otpManager: OTPManager = .shared,
        sessionManager: SessionManaging = SessionManager.shared
    ) {
        self.otpManager = otpManager
        self.sessionManager = sessionManager
    }

    var currentUser: AppUser? {
        if let firebaseUser = Auth.auth().currentUser {
            return mapUser(firebaseUser, provider: sessionManager.currentUser?.provider ?? .email)
        }
        return sessionManager.currentUser
    }

    func sendOTP(to email: String) async throws {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard EmailValidator.isValid(normalized) else { throw AuthError.invalidEmail }

        try await otpManager.sendOTP(to: normalized)
        sessionManager.pendingEmail = normalized
    }

    func verifyOTP(_ code: String, for email: String) async throws -> AppUser {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        try await otpManager.verifyOTP(code, for: normalized)

        let password = keychain.password(for: normalized) ?? UUID().uuidString
        keychain.save(password: password, for: normalized)

        let result: AuthDataResult
        do {
            result = try await createUser(email: normalized, password: password)
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                result = try await signInExistingUser(email: normalized, password: password)
            } else {
                throw AuthError.from(error)
            }
        }

        let user = mapUser(result.user, provider: .email)
        sessionManager.currentUser = user
        sessionManager.pendingEmail = nil
        otpManager.clear(for: normalized)
        return user
    }

    func signOut() throws {
        try Auth.auth().signOut()
        sessionManager.clearSession()
        keychain.clearAll()
    }

    private func createUser(email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: AuthError.from(error))
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthError.unknown)
                }
            }
        }
    }

    private func signInExistingUser(email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: AuthError.from(error))
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthError.unknown)
                }
            }
        }
    }

    private func mapUser(_ user: FirebaseAuth.User, provider: AuthProvider) -> AppUser {
        AppUser(
            uid: user.uid,
            displayName: user.displayName,
            email: user.email,
            photoURL: user.photoURL,
            provider: provider
        )
    }
}

/// Stores generated passwords for the email OTP sign-in flow (Keychain).
private final class EmailPasswordKeychain {
    private let service = "com.vikram.OkPeriodDemo.email-auth"

    func save(password: String, for email: String) {
        let data = Data(password.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: email,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func password(for email: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: email,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        return password
    }

    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}
