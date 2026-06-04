//
//  AppCoordinator.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let sessionManager: SessionManaging
    private let navigationController: UINavigationController

    init(window: UIWindow, sessionManager: SessionManaging = SessionManager.shared) {
        self.window = window
        self.sessionManager = sessionManager
        navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = false
        configureNavigationBarAppearance()
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        if sessionManager.isLoggedIn || Auth.auth().currentUser != nil {
            showHome(animated: false)
        } else {
            showAuth(animated: false)
        }
    }

    func showAuth(animated: Bool = true) {
        let viewController = AuthViewController()
        viewController.coordinator = self
        setRoot(viewController, animated: animated)
    }

    func showEmail(animated: Bool = true) {
        let viewController = EmailViewController()
        viewController.coordinator = self
        push(viewController, animated: animated)
    }

    func showOTP(email: String, animated: Bool = true) {
        let viewController = OTPViewController(email: email)
        viewController.coordinator = self
        push(viewController, animated: animated)
    }

    func showHome(animated: Bool = true) {
        let viewController = HomeViewController()
        viewController.coordinator = self
        setRoot(viewController, animated: animated)
    }

    private func push(_ viewController: UIViewController, animated: Bool) {
        if animated {
            let transition = UINavigationController.makeSmoothTransition()
            navigationController.view.layer.add(transition, forKey: kCATransition)
        }
        navigationController.pushViewController(viewController, animated: false)
    }

    private func setRoot(_ viewController: UIViewController, animated: Bool) {
        navigationController.setViewControllers([viewController], animated: false)
        if animated {
            viewController.view.fadeIn()
        }
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.background
        appearance.titleTextAttributes = [.foregroundColor: AppColors.textPrimary]
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = AppColors.primary
    }
}

import FirebaseAuth
