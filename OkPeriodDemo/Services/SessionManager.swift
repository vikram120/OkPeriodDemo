//
//  SessionManager.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation

protocol SessionManaging: AnyObject {
    var pendingEmail: String? { get set }
    var currentUser: AppUser? { get set }
    var isLoggedIn: Bool { get }
    func clearSession()
}

final class SessionManager: SessionManaging {
    static let shared = SessionManager()

    private enum Keys {
        static let pendingEmail = "session.pendingEmail"
        static let userData = "session.userData"
    }

    var pendingEmail: String? {
        get { UserDefaults.standard.string(forKey: Keys.pendingEmail) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pendingEmail) }
    }

    var currentUser: AppUser? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.userData) else { return nil }
            return try? JSONDecoder().decode(StoredUser.self, from: data).appUser
        }
        set {
            if let newValue {
                let stored = StoredUser(from: newValue)
                if let data = try? JSONEncoder().encode(stored) {
                    UserDefaults.standard.set(data, forKey: Keys.userData)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.userData)
            }
        }
    }

    var isLoggedIn: Bool { currentUser != nil }

    func clearSession() {
        pendingEmail = nil
        currentUser = nil
    }

    private init() {}
}

private struct StoredUser: Codable {
    let uid: String
    let displayName: String?
    let email: String?
    let photoURLString: String?
    let provider: String

    init(from user: AppUser) {
        uid = user.uid
        displayName = user.displayName
        email = user.email
        photoURLString = user.photoURL?.absoluteString
        provider = user.provider.rawValue
    }

    var appUser: AppUser {
        AppUser(
            uid: uid,
            displayName: displayName,
            email: email,
            photoURL: photoURLString.flatMap(URL.init(string:)),
            provider: AuthProvider(rawValue: provider) ?? .email
        )
    }
}
