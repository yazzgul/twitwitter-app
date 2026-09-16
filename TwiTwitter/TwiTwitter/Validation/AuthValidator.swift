//
//  AuthValidator.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation

enum AuthValidator {

    // Email

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    // Password

    static func isStrongPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let hasUpper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLower = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasDigit = password.range(of: "[0-9]", options: .regularExpression) != nil
        return hasUpper && hasLower && hasDigit
    }

    // Username

    static func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 3 && trimmed.count <= 30
    }

    // Sign Up

    static func validateSignUp(
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) throws {
        guard isValidUsername(username) else { throw AuthValidationError.emptyUsername }
        guard isValidEmail(email) else { throw AuthValidationError.invalidEmail }
        guard isStrongPassword(password) else { throw AuthValidationError.weakPassword }
        guard password == confirmPassword else { throw AuthValidationError.passwordsDoNotMatch }
    }

    // Sign In

    static func validateSignIn(email: String, password: String) throws {
        guard isValidEmail(email) else { throw AuthValidationError.invalidEmail }
    }
}
