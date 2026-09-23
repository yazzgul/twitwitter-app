//
//  PostsViewModel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

// Для чтения постов

import Foundation
import Combine

@MainActor
final class PostsViewModel: ObservableObject {

    @Published var posts: [Post] = []

    private let postService: PostServiceProtocol

    init(postService: PostServiceProtocol? = nil) {
        self.postService = postService ?? PostService()
    }

    func fetchFeed() {
        postService.observeFeed { [weak self] posts in
            self?.posts = posts
        }
    }

    func fetchUserPosts(uid: String) async -> [Post] {
        (try? await postService.fetchUserPosts(uid: uid)) ?? []
    }

    func stopObserving() {
        postService.stopObservingFeed()
    }
}
