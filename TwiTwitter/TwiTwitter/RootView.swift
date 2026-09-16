//
//  RootView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.userSession != nil {
//                переход к MainTabView()
            } else {
                SignInView()
            }
        }
    }
}
