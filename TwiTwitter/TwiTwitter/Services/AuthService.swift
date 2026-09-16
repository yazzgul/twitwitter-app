//
//  AuthService.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation
import FirebaseAuth

protocol AuthServiceProtocol {
    var currentUserID: String? { get }
    func createUser(email: String, password: String) async throws -> FirebaseAuth.User
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User
    func signOut() throws
}

final class AuthService: AuthServiceProtocol {

    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    func createUser(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }

    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
