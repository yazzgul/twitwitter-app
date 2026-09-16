//
//  Post.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var authorId: String
    var authorUsername: String
    var authorAvatarURL: String?
    var caption: String
    var imageURL: String?
    var createdAt: Date
}
