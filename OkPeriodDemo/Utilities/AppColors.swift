//
//  AppColors.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

enum AppColors {
    static let primary = UIColor(hex: "#4F46E5")
    static let background = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#0F172A")
            : UIColor(hex: "#F8FAFC")
    }
    static let surface = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#1E293B")
            : .white
    }
    static let textPrimary = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#F8FAFC")
            : UIColor(hex: "#0F172A")
    }
    static let textSecondary = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#94A3B8")
            : UIColor(hex: "#64748B")
    }
    static let success = UIColor(hex: "#10B981")
    static let error = UIColor(hex: "#EF4444")
    static let border = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#334155")
            : UIColor(hex: "#E2E8F0")
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

enum AppMetrics {
    static let cornerRadius: CGFloat = 12
    static let spacing: CGFloat = 16
    static let spacingLarge: CGFloat = 24
    static let buttonHeight: CGFloat = 52
}
