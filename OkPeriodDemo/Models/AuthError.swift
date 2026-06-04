//
//  AuthError.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation

enum AuthError: LocalizedError, Equatable {
    case emptyEmail
    case invalidEmail
    case invalidOTP
    case network
    case cancelled
    case firebase(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Please enter your email address."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidOTP:
            return "The code you entered is incorrect. Please try again."
        case .network:
            return "Please check your internet connection and try again."
        case .cancelled:
            return "Sign in was cancelled."
        case .firebase(let message):
            return message
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }

    static func from(_ error: Error) -> AuthError {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        if let authError = error as? AuthError {
            return authError
        }
        return .firebase(error.localizedDescription)
    }
}
