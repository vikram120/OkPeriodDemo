//
//  OTPInputView.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

protocol OTPInputViewDelegate: AnyObject {
    func otpInputView(_ view: OTPInputView, didComplete code: String)
    func otpInputView(_ view: OTPInputView, didUpdate code: String)
}

final class OTPInputView: UIView {
    weak var delegate: OTPInputViewDelegate?

    private let digitCount = 6
    private var fields: [OTPTextField] = []

    var code: String {
        fields.compactMap(\.text).joined()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        for index in 0..<digitCount {
            let field = OTPTextField()
            field.tag = index
            field.otpDelegate = self
            field.heightAnchor.constraint(equalToConstant: 56).isActive = true
            fields.append(field)
            stack.addArrangedSubview(field)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func focusFirstEmptyField() {
        if let field = fields.first(where: { ($0.text ?? "").isEmpty }) {
            field.becomeFirstResponder()
        } else {
            fields.last?.becomeFirstResponder()
        }
    }

    func clear() {
        fields.forEach { $0.text = "" }
        fields.first?.becomeFirstResponder()
    }

    func setErrorState(_ hasError: Bool) {
        let color = hasError ? AppColors.error.cgColor : AppColors.border.cgColor
        fields.forEach { $0.layer.borderColor = color }
    }
}

extension OTPInputView: OTPTextFieldDelegate {
    func otpTextField(_ textField: OTPTextField, didChange text: String) {
        setErrorState(false)
        delegate?.otpInputView(self, didUpdate: code)
        guard text.count == 1 else { return }
        let index = textField.tag
        if index < fields.count - 1 {
            fields[index + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if code.count == digitCount {
                delegate?.otpInputView(self, didComplete: code)
            }
        }
    }

    func otpTextFieldDidDeleteBackward(_ textField: OTPTextField) {
        let index = textField.tag
        if (textField.text ?? "").isEmpty, index > 0 {
            let previous = fields[index - 1]
            previous.text = ""
            previous.becomeFirstResponder()
        }
        delegate?.otpInputView(self, didUpdate: code)
    }
}
