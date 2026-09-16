//
//  UserService.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation
import FirebaseFirestore

protocol UserServiceProtocol {
    func createUser(_ user: AppUser) throws
    func fetchUser(uid: String) async throws -> AppUser?
}

final class UserService: UserServiceProtocol {

    private let db = Firestore.firestore()
    private let collection = "users"

    func createUser(_ user: AppUser) throws {
        try db.collection(collection).document(user.id).setData(from: user)
    }

    func fetchUser(uid: String) async throws -> AppUser? {
        let snapshot = try await db.collection(collection).document(uid).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: AppUser.self)
    }
}
