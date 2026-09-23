//
//  PostComposerViewModel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

// Для манипуляции с данными постов

import Combine
import PhotosUI
import SwiftUI

@MainActor
final class PostComposerViewModel: ObservableObject {

    @Published var caption: String = ""
    @Published var selectedImage: UIImage?
    @Published var errorMessage: String?
    @Published var isPosting = false

    private let postService: PostServiceProtocol
    private let storageService: StorageServiceProtocol
    private let loc: LocalizationManager

    init(
        postService: PostServiceProtocol? = nil,
        storageService: StorageServiceProtocol? = nil,
        loc: LocalizationManager? = nil
    ) {
        self.postService = postService ?? PostService()
        self.storageService = storageService ?? StorageService()
        self.loc = loc ?? .shared
    }

//      логика конвертации PhotosPickerItem в UIImage
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item,
            let data = try? await item.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else { return }
        selectedImage = uiImage
    }

    func publish(author: AppUser) async -> Bool {
        errorMessage = nil

        do {
            try PostValidator.validate(
                caption: caption,
                hasImage: selectedImage != nil
            )
        } catch let error as PostValidationError {
            errorMessage = loc.localized(error.localizationKey)
            return false
        } catch {
            return false
        }

        isPosting = true
        defer { isPosting = false }

        do {
            var imageURL: String?
            if let selectedImage,
                let data = selectedImage.jpegData(compressionQuality: 0.7)
            {
                imageURL = try await storageService.uploadPostImage(data)
                    .absoluteString
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
            errorMessage = loc.localized("error_post_publish_failed")
            return false
        }
    }
}
