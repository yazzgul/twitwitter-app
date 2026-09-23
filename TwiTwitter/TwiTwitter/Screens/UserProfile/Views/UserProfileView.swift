//
//  UserProfileView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

@MainActor
struct UserProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var vm = UserProfileViewModel()

//  если nil показываем профиль текущего пользователя
    var userId: String? = nil

    private var isOwnProfile: Bool {
        userId == nil || userId == authVM.currentUser?.id
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: vm.user?.avatarURL ?? "")) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill").foregroundColor(
                                .white
                            )
                        )
                }
                .frame(width: 90, height: 90)
                .clipShape(Circle())

                Text(vm.user?.username ?? "")
                    .font(.title2).fontWeight(.bold)

                Text(
                    String(
                        format: loc.localized("profile_posts_count"),
                        vm.posts.count
                    )
                )
                .font(.footnote).foregroundColor(.gray)

                if isOwnProfile {
                    Button(loc.localized("sign_out"), role: .destructive) {
                        authVM.signOut()
                    }
                    .padding(.top, 4)
                }

                Divider().padding(.top, 8)

                if vm.isLoading {
                    ProgressView().padding(.top, 24)
                } else {
                    LazyVStack(spacing: 18) {
                        ForEach(vm.posts) { post in
                            PostCard(post: post)
                        }
                    }
                }
            }
            .padding(.top, 24)
        }
        .navigationTitle(
            isOwnProfile
                ? loc.localized("profile_title") : "@\(vm.user?.username ?? "")"
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isOwnProfile {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        Image(systemName: "globe")
                    }
                }
            }
        }
        .task(id: userId) {
            let uid = userId ?? authVM.currentUser?.id
            guard let uid else { return }
            await vm.loadUser(
                userId: uid,
                knownUser: isOwnProfile ? authVM.currentUser : nil
            )
        }
    }
}
