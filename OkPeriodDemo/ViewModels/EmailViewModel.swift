//
//  EmailViewModel.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation

@MainActor
protocol EmailViewModelDelegate: AnyObject {
    func emailViewModel(_ viewModel: EmailViewModel, didRequestOTPFor email: String)
    func emailViewModel(_ viewModel: EmailViewModel, didFail error: AuthError)
    func emailViewModelDidUpdateLoading(_ viewModel: EmailViewModel, isLoading: Bool)
}

@MainActor
final class EmailViewModel {
    weak var delegate: EmailViewModelDelegate?

    private let authService: AuthServiceProtocol
    private let sessionManager: SessionManaging

    init(
        authService: AuthServiceProtocol = FirebaseAuthService(),
        sessionManager: SessionManaging = SessionManager.shared
    ) {
        self.authService = authService
        self.sessionManager = sessionManager
    }

    func continueTapped(email: String) {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            delegate?.emailViewModel(self, didFail: .emptyEmail)
            return
        }
        if !EmailValidator.isValid(trimmed) {
            delegate?.emailViewModel(self, didFail: .invalidEmail)
            return
        }

        delegate?.emailViewModelDidUpdateLoading(self, isLoading: true)
        Task {
            do {
                try await authService.sendOTP(to: trimmed)
                sessionManager.pendingEmail = trimmed
                delegate?.emailViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.emailViewModel(self, didRequestOTPFor: trimmed)
            } catch let error as AuthError {
                delegate?.emailViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.emailViewModel(self, didFail: error)
            } catch {
                delegate?.emailViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.emailViewModel(self, didFail: AuthError.from(error))
            }
        }
    }
}
