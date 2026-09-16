//
//  AuthValidationError.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation

enum AuthValidationError: LocalizedError, Equatable {
    case emptyUsername
    case invalidEmail
    case weakPassword
    case passwordsDoNotMatch

    var field: AuthField {
        switch self {
        case .emptyUsername:       return .username
        case .invalidEmail:        return .email
        case .weakPassword:        return .password
        case .passwordsDoNotMatch: return .confirmPassword

        }
    }

    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "Имя пользователя должно быть от 3 до 30 символов"
        case .invalidEmail:
            return "Некорректный email"
        case .weakPassword:
            return "Пароль должен быть не короче 8 символов и содержать заглавные, строчные буквы и цифру"
        case .passwordsDoNotMatch:
            return "Пароли не совпадают"
        }
    }
}
