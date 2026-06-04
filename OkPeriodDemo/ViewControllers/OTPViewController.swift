//
//  OTPViewController.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

final class OTPViewController: BaseViewController {
    weak var coordinator: AppCoordinator?

    private let viewModel: OTPViewModel
    private let otpInputView = OTPInputView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Verify your email"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.accessibilityTraits = .header
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var verifyButton: PrimaryButton = {
        let button = PrimaryButton(title: "Verify", style: .filled)
        button.isEnabled = false
        button.accessibilityLabel = "Verify code"
        button.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        return button
    }()

    private lazy var resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(AppColors.primary, for: .normal)
        button.setTitleColor(AppColors.textSecondary, for: .disabled)
        button.isEnabled = false
        button.accessibilityLabel = "Resend verification code"
        button.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(email: String) {
        viewModel = OTPViewModel(email: email)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verification"
        viewModel.delegate = self
        otpInputView.delegate = self
        subtitleLabel.text = "Enter the 6-digit code sent to \(viewModel.email)"
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onAppear()
        otpInputView.focusFirstEmptyField()
        stackView.fadeIn()
    }

    private func setupLayout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(otpInputView)
        stackView.addArrangedSubview(verifyButton)
        stackView.addArrangedSubview(resendButton)
        stackView.setCustomSpacing(AppMetrics.spacingLarge, after: subtitleLabel)

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppMetrics.spacingLarge),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: AppMetrics.spacingLarge),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -AppMetrics.spacingLarge)
        ])
        updateResendTitle(seconds: 60)
    }

    private func updateResendTitle(seconds: Int) {
        if seconds > 0 {
            resendButton.setTitle("Resend code in \(seconds)s", for: .normal)
            resendButton.isEnabled = false
        } else {
            resendButton.setTitle("Resend code", for: .normal)
            resendButton.isEnabled = true
        }
    }

    @objc private func verifyTapped() {
        viewModel.verify(code: otpInputView.code)
    }

    @objc private func resendTapped() {
        otpInputView.clear()
        verifyButton.isEnabled = false
        viewModel.resendOTP()
    }
}

extension OTPViewController: OTPViewModelDelegate {
    func otpViewModelDidVerify(_ viewModel: OTPViewModel) {
        coordinator?.showHome()
    }

    func otpViewModel(_ viewModel: OTPViewModel, didFail error: AuthError) {
        otpInputView.setErrorState(true)
        showError(error)
    }

    func otpViewModelDidUpdateLoading(_ viewModel: OTPViewModel, isLoading: Bool) {
        setLoading(isLoading)
        verifyButton.isEnabled = !isLoading && otpInputView.code.count == 6
    }

    func otpViewModel(_ viewModel: OTPViewModel, didUpdateCountdown seconds: Int) {
        updateResendTitle(seconds: seconds)
    }

    func otpViewModelDidEnableResend(_ viewModel: OTPViewModel) {
        resendButton.isEnabled = true
        updateResendTitle(seconds: 0)
    }
}

extension OTPViewController: OTPInputViewDelegate {
    func otpInputView(_ view: OTPInputView, didComplete code: String) {
        verifyButton.isEnabled = true
        viewModel.verify(code: code)
    }

    func otpInputView(_ view: OTPInputView, didUpdate code: String) {
        verifyButton.isEnabled = code.count == 6
        otpInputView.setErrorState(false)
    }
}
