//
//  PostValidationError.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation

enum PostValidationError: LocalizedError, Equatable {
    case emptyPost
    case captionTooLong

    var errorDescription: String? {
        switch self {
        case .emptyPost:
            return "Добавьте текст или фото к посту"
        case .captionTooLong:
            return "Подпись слишком длинная (максимум \(PostValidator.maxCaptionLength) символов)"
        }
    }
}
