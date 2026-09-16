//
//  UserProfileView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    /// если userId == nil, показывается профиль текущего пользователя
    var userId: String? = nil

    @StateObject var postsVM = PostsViewModel()
    @StateObject var userVM = UserProfileViewModel()
    @State private var userPosts: [Post] = []

    private var isOwnProfile: Bool {
        userId == nil || userId == authVM.currentUser?.id
    }

    private var displayUser: AppUser? {
        isOwnProfile ? authVM.currentUser : userVM.user
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: displayUser?.avatarURL ?? "")) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "person.fill").foregroundColor(.white))
                }
                .frame(width: 90, height: 90)
                .clipShape(Circle())

                Text(displayUser?.username ?? "")
                    .font(.title2).fontWeight(.bold)

                Text("\(userPosts.count) posts")
                    .font(.footnote).foregroundColor(.gray)

                if isOwnProfile {
                    Button("Sign out", role: .destructive) {
                        authVM.signOut()
                    }
                    .padding(.top, 4)
                }

                Divider().padding(.top, 8)

                LazyVStack(spacing: 18) {
                    ForEach(userPosts) { post in
                        PostCard(post: post)
                    }
                }
            }
            .padding(.top, 24)
        }
        .navigationTitle(isOwnProfile ? "Profile" : "@\(displayUser?.username ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let uid = userId ?? authVM.currentUser?.id
            guard let uid else { return }
            if !isOwnProfile {
                await userVM.fetchUser(uid: uid)
            }
            userPosts = await postsVM.fetchUserPosts(uid: uid)
        }
    }
}
