//
//  GoogleSignInService.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

final class GoogleSignInService: GoogleSignInServiceProtocol {
    private let sessionManager: SessionManaging

    init(sessionManager: SessionManaging = SessionManager.shared) {
        self.sessionManager = sessionManager
    }

    func signIn(presenting viewController: UIViewController) async throws -> AppUser {
        guard let clientID = FirebaseCore.FirebaseApp.app()?.options.clientID else {
            throw AuthError.firebase("Missing Firebase client ID.")
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
                if let error {
                    let nsError = error as NSError
                    if nsError.code == GIDSignInError.canceled.rawValue {
                        continuation.resume(throwing: AuthError.cancelled)
                    } else {
                        continuation.resume(throwing: AuthError.from(error))
                    }
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error {
                        continuation.resume(throwing: AuthError.from(error))
                        return
                    }
                    guard let firebaseUser = authResult?.user else {
                        continuation.resume(throwing: AuthError.unknown)
                        return
                    }

                    let appUser = AppUser(
                        uid: firebaseUser.uid,
                        displayName: firebaseUser.displayName ?? user.profile?.name,
                        email: firebaseUser.email ?? user.profile?.email,
                        photoURL: firebaseUser.photoURL ?? user.profile?.imageURL(withDimension: 200),
                        provider: .google
                    )
                    self?.sessionManager.currentUser = appUser
                    continuation.resume(returning: appUser)
                }
            }
        }
    }
}
