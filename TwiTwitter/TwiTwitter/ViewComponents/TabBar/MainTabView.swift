//
//  MainTabView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem { Label("Feed", systemImage: "house.fill") }

            NavigationStack {
                UserProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(.purple)
    }
}
