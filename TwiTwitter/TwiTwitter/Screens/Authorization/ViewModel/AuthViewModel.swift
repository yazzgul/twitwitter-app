//
//  AuthViewModel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Combine
import FirebaseAuth
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    @Published var fieldErrors: [AuthField: String] = [:]
    @Published var isLoading = false

    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    private let loc: LocalizationManager

    init(
        authService: AuthServiceProtocol? = nil,
        userService: UserServiceProtocol? = nil,
        loc: LocalizationManager? = nil
    ) {
        self.authService = authService ?? AuthService()
        self.userService = userService ?? UserService()
        self.loc = loc ?? .shared
        self.userSession = Auth.auth().currentUser

        Task { await loadCurrentUser() }
    }

    func signUp(
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async {
        fieldErrors.removeAll()

        do {
            try AuthValidator.validateSignUp(
                username: username,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
        } catch let error as AuthValidationError {
            fieldErrors[error.field] = loc.localized(error.localizationKey)
            return
        } catch {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let firebaseUser = try await authService.createUser(
                email: email,
                password: password
            )
            let newUser = AppUser(
                id: firebaseUser.uid,
                username: username,
                email: email,
                avatarURL: nil,
                createdAt: Date()
            )
            try userService.createUser(newUser)
            userSession = firebaseUser
            currentUser = newUser
        } catch {
            apply(remoteError: error, fallbackField: .email)
        }
    }

    func signIn(email: String, password: String) async {
        fieldErrors.removeAll()

        do {
            try AuthValidator.validateSignIn(email: email, password: password)
        } catch let error as AuthValidationError {
            fieldErrors[error.field] = loc.localized(error.localizationKey)
            return
        } catch {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let firebaseUser = try await authService.signIn(
                email: email,
                password: password
            )
            userSession = firebaseUser
            await loadCurrentUser()
        } catch {
            apply(remoteError: error, fallbackField: .password)
        }
    }

    func signOut() {
        try? authService.signOut()
        userSession = nil
        currentUser = nil
    }

    func clearError(for field: AuthField) {
        fieldErrors[field] = nil
    }

    private func loadCurrentUser() async {
        guard let uid = authService.currentUserID else { return }
        currentUser = try? await userService.fetchUser(uid: uid)
    }

    private func apply(remoteError error: Error, fallbackField: AuthField) {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            fieldErrors[fallbackField] = loc.localized("error_generic")
            return
        }
        switch code {
        case .emailAlreadyInUse:
            fieldErrors[.email] = loc.localized("error_email_in_use")
        case .invalidEmail:
            fieldErrors[.email] = loc.localized("error_invalid_email")
        case .weakPassword:
            fieldErrors[.password] = loc.localized("error_weak_password")
        case .wrongPassword, .userNotFound:
            fieldErrors[.password] = loc.localized("error_wrong_credentials")
        case .networkError:
            fieldErrors[fallbackField] = loc.localized("error_network")
        default:
            fieldErrors[fallbackField] = loc.localized("error_generic")
        }
    }
}
