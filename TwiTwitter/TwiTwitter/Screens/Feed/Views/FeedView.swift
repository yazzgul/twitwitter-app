//
//  FeedView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct FeedView: View {
//    только читает из вью модел
    @StateObject var vm = PostsViewModel()
    @State private var showNewPost = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(vm.posts, id: \.id) { post in
                        PostCard(post: post)
                    }
                }
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("TwiTwitter")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewPost = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView()
            }
            .navigationDestination(for: String.self) { authorId in
                UserProfileView(userId: authorId)
            }
        }
        .onAppear { vm.fetchFeed() }
    }
}
