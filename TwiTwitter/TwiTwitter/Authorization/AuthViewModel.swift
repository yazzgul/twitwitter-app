//
//  AuthViewModel.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    @Published var fieldErrors: [AuthField: String] = [:]
    @Published var isLoading = false

    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol

    init(
        authService: AuthServiceProtocol = AuthService(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.authService = authService
        self.userService = userService
        self.userSession = Auth.auth().currentUser
        Task { await loadCurrentUser() }
    }

    // Sign Up

    func signUp(username: String, email: String, password: String, confirmPassword: String) async {
        fieldErrors.removeAll()

        do {
            try AuthValidator.validateSignUp(
                username: username, email: email,
                password: password, confirmPassword: confirmPassword
            )
        } catch let error as AuthValidationError {
            fieldErrors[error.field] = error.errorDescription
            return
        } catch {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let firebaseUser = try await authService.createUser(email: email, password: password)
            let newUser = AppUser(
                id: firebaseUser.uid, username: username, email: email,
                avatarURL: nil, createdAt: Date()
            )
            try userService.createUser(newUser)
            userSession = firebaseUser
            currentUser = newUser
        } catch {
            apply(remoteError: error, fallbackField: .email)
        }
    }

    // Sign In

    func signIn(email: String, password: String) async {
        fieldErrors.removeAll()

        do {
            try AuthValidator.validateSignIn(email: email, password: password)
        } catch let error as AuthValidationError {
            fieldErrors[error.field] = error.errorDescription
            return
        } catch {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let firebaseUser = try await authService.signIn(email: email, password: password)
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

    /// Сбрасывает ошибку конкретного поля — вызывать при изменении текста в TextField.
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
            fieldErrors[fallbackField] = error.localizedDescription
            return
        }
        switch code {
        case .emailAlreadyInUse:
            fieldErrors[.email] = "Этот email уже используется"
        case .invalidEmail:
            fieldErrors[.email] = "Некорректный email"
        case .weakPassword:
            fieldErrors[.password] = "Пароль слишком простой"
        case .wrongPassword, .userNotFound:
            fieldErrors[.password] = "Неверный email или пароль"
        case .networkError:
            fieldErrors[fallbackField] = "Нет соединения с интернетом"
        default:
            fieldErrors[fallbackField] = error.localizedDescription
        }
    }
}
