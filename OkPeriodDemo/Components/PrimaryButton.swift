//
//  PrimaryButton.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

enum PrimaryButtonStyle {
    case filled
    case outlined
    case google
}

final class PrimaryButton: UIButton {
    var style: PrimaryButtonStyle = .filled {
        didSet { applyStyle() }
    }

    override var isEnabled: Bool {
        didSet { updateEnabledAppearance() }
    }

    init(title: String, style: PrimaryButtonStyle = .filled) {
        super.init(frame: .zero)
        self.style = style
        setTitle(title, for: .normal)
        setup()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        applyStyle()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: AppMetrics.buttonHeight).isActive = true
        layer.cornerRadius = AppMetrics.cornerRadius
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func applyStyle() {
        switch style {
        case .filled:
            backgroundColor = AppColors.primary
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
        case .outlined:
            backgroundColor = AppColors.surface
            setTitleColor(AppColors.primary, for: .normal)
            layer.borderWidth = 1.5
            layer.borderColor = AppColors.border.cgColor
        case .google:
            backgroundColor = AppColors.surface
            setTitleColor(AppColors.textPrimary, for: .normal)
            layer.borderWidth = 1.5
            layer.borderColor = AppColors.border.cgColor
        }
        updateEnabledAppearance()
    }

    private func updateEnabledAppearance() {
        alpha = isEnabled ? 1 : 0.5
    }

    @objc private func handleTouchDown() {
        applyTapScaleEffect()
    }

    @objc private func handleTouchUp() {}
}
