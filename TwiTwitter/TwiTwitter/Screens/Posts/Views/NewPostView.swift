//
//  NewPostView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI
import PhotosUI

struct NewPostView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var composerVM = PostComposerViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var caption = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    @FocusState private var isCaptionFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ZStack {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
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
                                        Text("Выбрать фото")
                                            .font(.subheadline)
                                    }
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }

                if let error = composerVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                TextField("Подпись к посту...", text: $caption, axis: .vertical)
                    .lineLimit(3...6)
                    .authFieldStyle()
                    .focused($isCaptionFocused)

                Spacer()

                Button {
                    print("🔍 currentUser =", authVM.currentUser as Any)
                    print("🔍 userSession =", authVM.userSession as Any)
                    guard let user = authVM.currentUser else { return }
                    Task {
                        let success = await composerVM.publish(author: user, caption: caption, image: selectedImage)
                        if success { dismiss() }
                    }
                } label: {
                    Group {
                        if composerVM.isPosting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Опубликовать").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .background(.linearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(composerVM.isPosting)
            }
            .padding(20)
            .contentShape(Rectangle())
            .onTapGesture {
                isCaptionFocused = false
            }
            .navigationTitle("Новый пост")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
