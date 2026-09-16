//
//  StorageService.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation
import FirebaseStorage

protocol StorageServiceProtocol {
    func uploadPostImage(_ data: Data) async throws -> URL
}

final class StorageService: StorageServiceProtocol {

    private let storage = Storage.storage()

    func uploadPostImage(_ data: Data) async throws -> URL {
        let ref = storage.reference().child("post_images/\(UUID().uuidString).jpg")
        _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL()
    }
}
