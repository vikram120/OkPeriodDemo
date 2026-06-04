//
//  AuthViewController.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

final class AuthViewController: BaseViewController {
    weak var coordinator: AppCoordinator?
    private let viewModel = AuthViewModel()

    private let logoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.primary.withAlphaComponent(0.12)
        view.layer.cornerRadius = 28
        return view
    }()

    private let logoImageView: UIImageView = {
        let image = UIImage(systemName: "lock.shield.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold))
        let imageView = UIImageView(image: image)
        imageView.tintColor = AppColors.primary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityLabel = "App logo"
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.accessibilityTraits = .header
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to continue to your account"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var googleButton: PrimaryButton = {
        let button = PrimaryButton(title: "Continue with Google", style: .google)
        button.accessibilityLabel = "Continue with Google"
        button.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        return button
    }()

    private lazy var emailButton: PrimaryButton = {
        let button = PrimaryButton(title: "Continue with Email", style: .filled)
        button.accessibilityLabel = "Continue with Email"
        button.addTarget(self, action: #selector(emailTapped), for: .touchUpInside)
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateContent()
    }

    private func setupLayout() {
        logoContainer.addSubview(logoImageView)
        view.addSubview(stackView)

        let headerStack = UIStackView(arrangedSubviews: [logoContainer, titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = AppMetrics.spacing
        headerStack.setCustomSpacing(AppMetrics.spacingLarge, after: logoContainer)

        stackView.addArrangedSubview(headerStack)
        stackView.addArrangedSubview(googleButton)
        stackView.addArrangedSubview(emailButton)
        stackView.setCustomSpacing(AppMetrics.spacingLarge, after: headerStack)

        NSLayoutConstraint.activate([
            logoContainer.widthAnchor.constraint(equalToConstant: 88),
            logoContainer.heightAnchor.constraint(equalToConstant: 88),
            logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: AppMetrics.spacingLarge),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -AppMetrics.spacingLarge),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func animateContent() {
        stackView.arrangedSubviews.forEach { $0.alpha = 0 }
        for (index, subview) in stackView.arrangedSubviews.enumerated() {
            subview.fadeIn(delay: Double(index) * 0.08)
        }
    }

    @objc private func googleTapped() {
        viewModel.continueWithGoogle(presenting: self)
    }

    @objc private func emailTapped() {
        viewModel.continueWithEmail()
    }
}

extension AuthViewController: AuthViewModelDelegate {
    func authViewModelDidSignIn(_ viewModel: AuthViewModel) {
        coordinator?.showHome()
    }

    func authViewModel(_ viewModel: AuthViewModel, didFail error: AuthError) {
        showError(error)
    }

    func authViewModelDidRequestEmail(_ viewModel: AuthViewModel) {
        coordinator?.showEmail()
    }

    func authViewModelDidUpdateLoading(_ viewModel: AuthViewModel, isLoading: Bool) {
        setLoading(isLoading)
    }
}
