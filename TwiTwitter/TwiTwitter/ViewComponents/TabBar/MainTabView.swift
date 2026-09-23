//
//  MainTabView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label(loc.localized("tab_feed"), systemImage: "house.fill")
                }

            NavigationStack {
                UserProfileView()
            }
            .tabItem {
                Label(
                    loc.localized("tab_profile"),
                    systemImage: "person.crop.circle"
                )
            }
        }
        .tint(.purple)
    }
}
