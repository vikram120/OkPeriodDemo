//
//  User.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation

struct AppUser: Equatable {
    let uid: String
    let displayName: String?
    let email: String?
    let photoURL: URL?
    let provider: AuthProvider

    var resolvedDisplayName: String {
        if let displayName, !displayName.isEmpty { return displayName }
        if let email { return email.components(separatedBy: "@").first ?? "User" }
        return "User"
    }
}

enum AuthProvider: String, Equatable {
    case google
    case email
}
