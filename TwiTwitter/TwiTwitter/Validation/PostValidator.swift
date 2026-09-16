//
//  PostValidator.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation

enum PostValidator {

    static let maxCaptionLength = 500

    static func validate(caption: String, hasImage: Bool) throws {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || hasImage else {
            throw PostValidationError.emptyPost
        }
        guard trimmed.count <= maxCaptionLength else {
            throw PostValidationError.captionTooLong
        }
    }
}
