//
//  PostImageLabel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 23.09.2026.
//

import SwiftUI

//  превью выбранного изображения для PhotosPicker
struct PostImageLabel: View {
    let image: UIImage?
    let placeholder: String

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(height: 280)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 34))
                            Text(placeholder)
                                .font(.subheadline)
                        }
                        .foregroundColor(.gray)
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PostImageLabel(image: nil, placeholder: "Choose photo")
        PostImageLabel(
            image: UIImage(systemName: "photo"),
            placeholder: "Choose photo"
        )
    }
    .padding()
}
