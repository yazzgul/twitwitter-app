//
//  PostCard.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct PostCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(value: post.authorId) {
                HStack {
                    AsyncImage(url: URL(string: post.authorAvatarURL ?? "")) {
                        phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(post.authorUsername)")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text(
                            post.createdAt,
                            format: .dateTime.day().month().year().hour()
                                .minute()
                        )
                        .font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if !post.caption.isEmpty {
                Text(post.caption).font(.body)
            }

            if let urlStr = post.imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.15))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .clipped()
            }
        }
        .postCardStyle()
        .padding(.horizontal, 14)
    }
}
