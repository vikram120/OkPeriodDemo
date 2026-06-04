//
//  AuthServiceProtocol.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation
import UIKit

protocol AuthServiceProtocol: AnyObject {
    var currentUser: AppUser? { get }
    func sendOTP(to email: String) async throws
    func verifyOTP(_ code: String, for email: String) async throws -> AppUser
    func signOut() throws
}

protocol GoogleSignInServiceProtocol: AnyObject {
    func signIn(presenting viewController: UIViewController) async throws -> AppUser
}
