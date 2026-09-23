//
//  AuthValidationError.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation

enum AuthValidationError: Error, Equatable {
    case emptyUsername
    case invalidEmail
    case weakPassword
    case passwordsDoNotMatch

    var field: AuthField {
        switch self {
        case .emptyUsername: return .username
        case .invalidEmail: return .email
        case .weakPassword: return .password
        case .passwordsDoNotMatch: return .confirmPassword
        }
    }

    var localizationKey: String {
        switch self {
        case .emptyUsername: return "error_empty_username"
        case .invalidEmail: return "error_invalid_email"
        case .weakPassword: return "error_weak_password"
        case .passwordsDoNotMatch: return "error_passwords_mismatch"
        }
    }
}
