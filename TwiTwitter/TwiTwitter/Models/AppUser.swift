//
//  AppUser.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation

struct AppUser: Identifiable, Codable {
    var id: String            // uid
    var username: String
    var email: String
    var avatarURL: String?
    var createdAt: Date
}
