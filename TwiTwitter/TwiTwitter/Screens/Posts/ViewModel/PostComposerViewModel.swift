//
//  PostComposerViewModel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

// Для манипуляции с данными постов

import SwiftUI
import Combine

@MainActor
final class PostComposerViewModel: ObservableObject {

    @Published var errorMessage: String?
    @Published var isPosting = false

    private let postService: PostServiceProtocol
    private let storageService: StorageServiceProtocol

    init(
        postService: PostServiceProtocol = PostService(),
        storageService: StorageServiceProtocol = StorageService()
    ) {
        self.postService = postService
        self.storageService = storageService
    }

    /// возвращает true при успехе, по этому флагу view закрывает экран
    func publish(author: AppUser, caption: String, image: UIImage?) async -> Bool {
        errorMessage = nil

        do {
            try PostValidator.validate(caption: caption, hasImage: image != nil)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }

        isPosting = true
        defer { isPosting = false }

        do {
            var imageURL: String?
            if let image, let data = image.jpegData(compressionQuality: 0.7) {
                imageURL = try await storageService.uploadPostImage(data).absoluteString
            }

            let post = Post(
                authorId: author.id,
                authorUsername: author.username,
                authorAvatarURL: author.avatarURL,
                caption: caption,
                imageURL: imageURL,
                createdAt: Date()
            )
            try postService.createPost(post)
            return true
        } catch {
            errorMessage = "Не удалось опубликовать пост. Попробуйте ещё раз."
            return false
        }
    }
}
