//
//  EmailViewController.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

final class EmailViewController: BaseViewController {
    weak var coordinator: AppCoordinator?
    private let viewModel = EmailViewModel()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.accessibilityTraits = .header
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "We'll send you a one-time verification code"
        label.font = .systemFont(ofSize: 16)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email address"
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.textContentType = .emailAddress
        field.borderStyle = .none
        field.backgroundColor = AppColors.surface
        field.textColor = AppColors.textPrimary
        field.font = .systemFont(ofSize: 17)
        field.layer.cornerRadius = AppMetrics.cornerRadius
        field.layer.borderWidth = 1.5
        field.layer.borderColor = AppColors.border.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
        field.accessibilityLabel = "Email address"
        return field
    }()

    private lazy var continueButton: PrimaryButton = {
        let button = PrimaryButton(title: "Continue", style: .filled)
        button.accessibilityLabel = "Continue"
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Email"
        viewModel.delegate = self
        emailField.delegate = self
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
        stackView.fadeIn()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        emailField.layer.borderColor = AppColors.border.cgColor
    }

    private func setupLayout() {
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.heightAnchor.constraint(equalToConstant: AppMetrics.buttonHeight).isActive = true

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(continueButton)
        stackView.setCustomSpacing(AppMetrics.spacingLarge, after: subtitleLabel)

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppMetrics.spacingLarge),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: AppMetrics.spacingLarge),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -AppMetrics.spacingLarge)
        ])
    }

    @objc private func continueTapped() {
        view.endEditing(true)
        viewModel.continueTapped(email: emailField.text ?? "")
    }
}

extension EmailViewController: EmailViewModelDelegate {
    func emailViewModel(_ viewModel: EmailViewModel, didRequestOTPFor email: String) {
        coordinator?.showOTP(email: email)
    }

    func emailViewModel(_ viewModel: EmailViewModel, didFail error: AuthError) {
        emailField.layer.borderColor = AppColors.error.cgColor
        showError(error)
    }

    func emailViewModelDidUpdateLoading(_ viewModel: EmailViewModel, isLoading: Bool) {
        setLoading(isLoading)
        continueButton.isEnabled = !isLoading
    }
}

extension EmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueTapped()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColors.primary.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColors.border.cgColor
    }
}
