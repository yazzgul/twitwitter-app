//
//  PostService.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation
import FirebaseFirestore

protocol PostServiceProtocol {
    func observeFeed(onChange: @escaping ([Post]) -> Void)
    func stopObservingFeed()
    func fetchUserPosts(uid: String) async throws -> [Post]
    func createPost(_ post: Post) throws
}

final class PostService: PostServiceProtocol {

    private let db = Firestore.firestore()
    private let collection = "posts"
    private var feedListener: ListenerRegistration?

    func observeFeed(onChange: @escaping ([Post]) -> Void) {
        feedListener = db.collection(collection)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, _ in
                let posts = snapshot?.documents.compactMap { doc -> Post? in
                    var post = try? doc.data(as: Post.self)
                    post?.id = doc.documentID
                    return post
                } ?? []
                onChange(posts)
            }
    }

    func stopObservingFeed() {
        feedListener?.remove()
        feedListener = nil
    }

    func fetchUserPosts(uid: String) async throws -> [Post] {
        let snapshot = try await db.collection(collection)
            .whereField("authorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Post.self) }
    }

    func createPost(_ post: Post) throws {
        try db.collection(collection).addDocument(from: post)
    }
}
