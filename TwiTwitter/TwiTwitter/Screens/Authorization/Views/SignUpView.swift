//
//  SignUpView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var loc: LocalizationManager

    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        VStack(spacing: 18) {
            Text(loc.localized("create_account"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.top, 40)

            VStack(spacing: 14) {
                ValidatedField(error: authVM.fieldErrors[.username]) {
                    TextField(loc.localized("username_placeholder"), text: $username)
                        .modifier(FieldStyle())
                        .onChange(of: username) { _, _ in
                            authVM.clearError(for: .username)
                        }
                }

                ValidatedField(error: authVM.fieldErrors[.email]) {
                    TextField(loc.localized("email_placeholder"), text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .modifier(FieldStyle())
                        .onChange(of: email) { _, _ in
                            authVM.clearError(for: .email)
                        }
                }

                ValidatedField(error: authVM.fieldErrors[.password]) {
                    SecureField(
                        loc.localized("password_placeholder"),
                        text: $password
                    ).modifier(FieldStyle())
                        .onChange(of: password) { _, _ in
                            authVM.clearError(for: .password)
                        }
                }

                ValidatedField(error: authVM.fieldErrors[.confirmPassword]) {
                    SecureField(
                        loc.localized("confirm_password_placeholder"),
                        text: $password
                    ).modifier(FieldStyle())
                        .onChange(of: confirmPassword) { _, _ in
                            authVM.clearError(for: .confirmPassword)
                        }
                }
            }

            Button {
                Task {
                    await authVM.signUp(
                        username: username,
                        email: email,
                        password: password,
                        confirmPassword: confirmPassword
                    )
                    if authVM.userSession != nil { dismiss() }
                }
            } label: {
                Group {
                    if authVM.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(loc.localized("sign_up_link")).fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    .linearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(authVM.isLoading)

            Spacer()
        }
        .padding(.horizontal, 28)
    }
}
