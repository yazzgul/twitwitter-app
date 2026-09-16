//
//  UserProfileViewModel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation
import Combine

@MainActor
final class UserProfileViewModel: ObservableObject {

    @Published var user: AppUser?

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    func fetchUser(uid: String) async {
        user = try? await userService.fetchUser(uid: uid)
    }
}
