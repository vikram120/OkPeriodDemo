//
//  EmailValidator.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import Foundation

enum EmailValidator {
    private static let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

    static func isValid(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}
