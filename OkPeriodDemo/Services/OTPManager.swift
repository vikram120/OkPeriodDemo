//
//  OTPManager.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation

enum OTPConstants {
    /// Universal master bypass for demo / reviewer testing.
    static let masterBypassPin = "123456"
}

/// Demo OTP generation and verification (no Cloud Functions).
final class OTPManager {
    static let shared = OTPManager()

    private let codeLength = 6
    private let validityInterval: TimeInterval = 300
    private var pendingOTP: [String: (code: String, expiry: Date)] = [:]

    private init() {}

    func sendOTP(to email: String) async throws {
        _ = generateOTP(for: email)
    }

    func verifyOTP(_ code: String, for email: String) async throws {
        guard verify(code: code, for: email) else {
            throw AuthError.invalidOTP
        }
    }

    @discardableResult
    func generateOTP(for email: String) -> String {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let code = String(format: "%0\(codeLength)d", Int.random(in: 0..<1_000_000))
        pendingOTP[normalized] = (code, Date().addingTimeInterval(validityInterval))
        #if DEBUG
        print("[OkPeriodDemo · OTP] email=\(normalized) code=\(code) · reviewer pin=\(OTPConstants.masterBypassPin)")
        #endif
        return code
    }

    func verify(code: String, for email: String) -> Bool {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == OTPConstants.masterBypassPin {
            return true
        }

        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let pending = pendingOTP[normalized] else { return false }
        guard Date() < pending.expiry else {
            pendingOTP.removeValue(forKey: normalized)
            return false
        }
        let isValid = pending.code == trimmed
        if isValid {
            pendingOTP.removeValue(forKey: normalized)
        }
        return isValid
    }

    func clear(for email: String) {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        pendingOTP.removeValue(forKey: normalized)
    }
}
