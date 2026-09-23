//
//  UserProfileViewModel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Combine
import Foundation

@MainActor
final class UserProfileViewModel: ObservableObject {

    @Published var user: AppUser?
    @Published var posts: [Post] = []
    @Published var isLoading = false

    private let userService: UserServiceProtocol
    private let postService: PostServiceProtocol

    init(
        userService: UserServiceProtocol? = nil,
        postService: PostServiceProtocol? = nil
    ) {
        self.userService = userService ?? UserService()
        self.postService = postService ?? PostService()
    }

    //  knownUser если это профиль текущего пользователя данные уже есть в AuthViewModel
    func loadUser(userId: String, knownUser: AppUser? = nil) async {
        isLoading = true
        defer { isLoading = false }

        if let knownUser {
            user = knownUser
        } else {
            user = try? await userService.fetchUser(uid: userId)
        }

        posts = (try? await postService.fetchUserPosts(uid: userId)) ?? []
    }
}
