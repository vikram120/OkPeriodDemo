//
//  AuthViewModel.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation
import UIKit

@MainActor
protocol AuthViewModelDelegate: AnyObject {
    func authViewModelDidSignIn(_ viewModel: AuthViewModel)
    func authViewModel(_ viewModel: AuthViewModel, didFail error: AuthError)
    func authViewModelDidRequestEmail(_ viewModel: AuthViewModel)
    func authViewModelDidUpdateLoading(_ viewModel: AuthViewModel, isLoading: Bool)
}

@MainActor
final class AuthViewModel {
    weak var delegate: AuthViewModelDelegate?

    private let googleSignInService: GoogleSignInServiceProtocol

    init(googleSignInService: GoogleSignInServiceProtocol = GoogleSignInService()) {
        self.googleSignInService = googleSignInService
    }

    func continueWithGoogle(presenting viewController: UIViewController) {
        delegate?.authViewModelDidUpdateLoading(self, isLoading: true)
        Task {
            do {
                _ = try await googleSignInService.signIn(presenting: viewController)
                delegate?.authViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.authViewModelDidSignIn(self)
            } catch let error as AuthError {
                delegate?.authViewModelDidUpdateLoading(self, isLoading: false)
                if case .cancelled = error { return }
                delegate?.authViewModel(self, didFail: error)
            } catch {
                delegate?.authViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.authViewModel(self, didFail: AuthError.from(error))
            }
        }
    }

    func continueWithEmail() {
        delegate?.authViewModelDidRequestEmail(self)
    }
}
