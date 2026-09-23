//
//  NewPostView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import PhotosUI
import SwiftUI

@MainActor
struct NewPostView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var loc: LocalizationManager
    @StateObject var composerVM = PostComposerViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                photoPicker

                if let error = composerVM.errorMessage {
                    Text(error).font(.caption).foregroundColor(.red)
                }

                TextField(
                    loc.localized("caption_placeholder"),
                    text: $composerVM.caption,
                    axis: .vertical
                )
                .lineLimit(3...6)
                .authFieldStyle()

                Spacer()

                Button {
                    guard let user = authVM.currentUser else { return }
                    Task {
                        let success = await composerVM.publish(author: user)
                        if success { dismiss() }
                    }
                } label: {
                    Group {
                        if composerVM.isPosting {
                            ProgressView().tint(.white)
                        } else {
                            Text(loc.localized("publish")).fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .background(
                    .linearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(composerVM.isPosting)
            }
            .padding(20)
            .navigationTitle(loc.localized("new_post_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.localized("cancel")) { dismiss() }
                }
            }
        }
    }

    @MainActor
    @ViewBuilder
    private var photoPicker: some View {
        let image = composerVM.selectedImage
        let placeholder = loc.localized("choose_photo")

        PhotosPicker(selection: $selectedItem, matching: .images) {
            PostImageLabel(image: image, placeholder: placeholder)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task { await composerVM.loadImage(from: newItem) }
        }
    }
}
