//
//  OTPTextField.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

protocol OTPTextFieldDelegate: AnyObject {
    func otpTextField(_ textField: OTPTextField, didChange text: String)
    func otpTextFieldDidDeleteBackward(_ textField: OTPTextField)
}

final class OTPTextField: UITextField {
    weak var otpDelegate: OTPTextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        textAlignment = .center
        font = .monospacedDigitSystemFont(ofSize: 24, weight: .semibold)
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        layer.cornerRadius = AppMetrics.cornerRadius
        layer.borderWidth = 1.5
        layer.borderColor = AppColors.border.cgColor
        backgroundColor = AppColors.surface
        textColor = AppColors.textPrimary
        tintColor = AppColors.primary
        delegate = self
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        accessibilityLabel = "OTP digit"
    }

    @objc private func textDidChange() {
        if let text, text.count > 1 {
            self.text = String(text.suffix(1))
        }
        otpDelegate?.otpTextField(self, didChange: text ?? "")
    }
}

extension OTPTextField: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty {
            otpDelegate?.otpTextFieldDidDeleteBackward(self)
            return true
        }
        let allowed = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        let current = textField.text ?? ""
        return allowed && current.count < 1
    }
}
