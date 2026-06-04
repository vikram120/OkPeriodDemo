//
//  OTPViewModel.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation

@MainActor
protocol OTPViewModelDelegate: AnyObject {
    func otpViewModelDidVerify(_ viewModel: OTPViewModel)
    func otpViewModel(_ viewModel: OTPViewModel, didFail error: AuthError)
    func otpViewModelDidUpdateLoading(_ viewModel: OTPViewModel, isLoading: Bool)
    func otpViewModel(_ viewModel: OTPViewModel, didUpdateCountdown seconds: Int)
    func otpViewModelDidEnableResend(_ viewModel: OTPViewModel)
}

@MainActor
final class OTPViewModel {
    weak var delegate: OTPViewModelDelegate?

    let email: String
    private let authService: AuthServiceProtocol
    private let otpManager: OTPManager

    private var countdownTimer: Timer?
    private(set) var remainingSeconds = 60
    private let resendInterval = 60

    init(
        email: String,
        authService: AuthServiceProtocol = FirebaseAuthService(),
        otpManager: OTPManager = .shared
    ) {
        self.email = email
        self.authService = authService
        self.otpManager = otpManager
    }

    deinit {
        countdownTimer?.invalidate()
    }

    func onAppear() {
        startCountdown()
    }

    func verify(code: String) {
        guard code.count == 6 else {
            delegate?.otpViewModel(self, didFail: .invalidOTP)
            return
        }

        delegate?.otpViewModelDidUpdateLoading(self, isLoading: true)
        Task {
            do {
                _ = try await authService.verifyOTP(code, for: email)
                delegate?.otpViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.otpViewModelDidVerify(self)
            } catch let error as AuthError {
                delegate?.otpViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.otpViewModel(self, didFail: error)
            } catch {
                delegate?.otpViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.otpViewModel(self, didFail: AuthError.from(error))
            }
        }
    }

    func resendOTP() {
        guard remainingSeconds == 0 else { return }
        delegate?.otpViewModelDidUpdateLoading(self, isLoading: true)
        Task {
            do {
                try await authService.sendOTP(to: email)
                delegate?.otpViewModelDidUpdateLoading(self, isLoading: false)
                remainingSeconds = resendInterval
                delegate?.otpViewModel(self, didUpdateCountdown: remainingSeconds)
                delegate?.otpViewModelDidEnableResend(self)
                startCountdown()
            } catch let error as AuthError {
                delegate?.otpViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.otpViewModel(self, didFail: error)
            } catch {
                delegate?.otpViewModelDidUpdateLoading(self, isLoading: false)
                delegate?.otpViewModel(self, didFail: AuthError.from(error))
            }
        }
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        remainingSeconds = resendInterval
        delegate?.otpViewModel(self, didUpdateCountdown: remainingSeconds)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                self.remainingSeconds -= 1
                self.delegate?.otpViewModel(self, didUpdateCountdown: max(self.remainingSeconds, 0))
                if self.remainingSeconds <= 0 {
                    timer.invalidate()
                    self.delegate?.otpViewModelDidEnableResend(self)
                }
            }
        }
    }
}
