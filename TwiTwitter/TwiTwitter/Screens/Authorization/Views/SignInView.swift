//
//  SignInView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var loc: LocalizationManager

    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer()

                Text("TwiTwitter")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                VStack(spacing: 14) {
                    ValidatedField(error: authVM.fieldErrors[.email]) {
                        TextField(
                            loc.localized("email_placeholder"),
                            text: $email
                        ).textInputAutocapitalization(.never)
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
                }

                Button {
                    Task {
                        await authVM.signIn(email: email, password: password)
                    }
                } label: {
                    Group {
                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(loc.localized("sign_in")).fontWeight(.semibold)
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
                .padding(.top, 8)

                Spacer()

                Button {
                    showSignUp = true
                } label: {
                    HStack(spacing: 4) {
                        Text(loc.localized("no_account_prompt"))
                            .foregroundColor(.gray)
                        Text(loc.localized("sign_up_link"))
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 28)
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
