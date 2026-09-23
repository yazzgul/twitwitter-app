//
//  LanguageSettingsView.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 23.09.2026.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        List {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    loc.currentLanguage = language
                } label: {
                    HStack {
                        Text(language.displayName)
                            .foregroundColor(.primary)
                        Spacer()
                        if loc.currentLanguage == language {
                            Image(systemName: "checkmark")
                                .foregroundColor(.purple)
                        }
                    }
                }
            }
        }
        .navigationTitle(loc.localized("language_settings_title"))
    }
}
