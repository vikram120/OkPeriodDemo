//
//  HomeViewModel.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation
import GoogleSignIn

@MainActor
protocol HomeViewModelDelegate: AnyObject {
    func homeViewModelDidSignOut(_ viewModel: HomeViewModel)
    func homeViewModel(_ viewModel: HomeViewModel, didFail error: AuthError)
}

@MainActor
final class HomeViewModel {
    weak var delegate: HomeViewModelDelegate?

    private let authService: AuthServiceProtocol
    private let googleSignInService: GoogleSignInServiceProtocol
    private let sessionManager: SessionManaging

    var user: AppUser? {
        authService.currentUser ?? sessionManager.currentUser
    }

    init(
        authService: AuthServiceProtocol = FirebaseAuthService(),
        googleSignInService: GoogleSignInServiceProtocol = GoogleSignInService(),
        sessionManager: SessionManaging = SessionManager.shared
    ) {
        self.authService = authService
        self.googleSignInService = googleSignInService
        self.sessionManager = sessionManager
    }

    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try authService.signOut()
            delegate?.homeViewModelDidSignOut(self)
        } catch {
            delegate?.homeViewModel(self, didFail: AuthError.from(error))
        }
    }
}
