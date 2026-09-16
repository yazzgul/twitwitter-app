//
//  SignUpView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        VStack(spacing: 18) {
            Text("Create an account")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.top, 40)

            VStack(spacing: 14) {
                ValidatedField(error: authVM.fieldErrors[.username]) {
                    TextField("Username", text: $username)
                        .modifier(FieldStyle())
                        .onChange(of: username) { _, _ in authVM.clearError(for: .username) }
                }

                ValidatedField(error: authVM.fieldErrors[.email]) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .modifier(FieldStyle())
                        .onChange(of: email) { _, _ in authVM.clearError(for: .email) }
                }

                ValidatedField(error: authVM.fieldErrors[.password]) {
                    SecureField("Password", text: $password)
                        .modifier(FieldStyle())
                        .onChange(of: password) { _, _ in authVM.clearError(for: .password) }
                }

                ValidatedField(error: authVM.fieldErrors[.confirmPassword]) {
                    SecureField("Password again", text: $confirmPassword)
                        .modifier(FieldStyle())
                        .onChange(of: confirmPassword) { _, _ in authVM.clearError(for: .confirmPassword) }
                }
            }

            Button {
                Task {
                    await authVM.signUp(
                        username: username, email: email,
                        password: password, confirmPassword: confirmPassword
                    )
                    if authVM.userSession != nil { dismiss() }
                }
            } label: {
                Group {
                    if authVM.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign Up").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.linearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(authVM.isLoading)

            Spacer()
        }
        .padding(.horizontal, 28)
    }
}
