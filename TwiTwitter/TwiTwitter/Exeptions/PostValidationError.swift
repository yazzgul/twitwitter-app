//
//  PostValidationError.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation

enum PostValidationError: Error, Equatable {
    case emptyPost
    case captionTooLong

    var localizationKey: String {
        switch self {
        case .emptyPost: return "error_empty_post"
        case .captionTooLong: return "error_caption_too_long"
        }
    }
}
