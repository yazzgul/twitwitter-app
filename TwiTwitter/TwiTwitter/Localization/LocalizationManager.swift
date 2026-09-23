//
//  LocalizationManager.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 23.09.2026.
//

import Combine
import SwiftUI

//  единая точка входа для локализации: хранит выбранный язык в UserDefaults,
//  подгружает нужный .lproj бандл и позволяет переключать язык без перезапуска приложения
@MainActor
final class LocalizationManager: ObservableObject {

    static let shared = LocalizationManager()

    @AppStorage("app_language") private var storedLanguage: String = AppLanguage
        .russian.rawValue
    {
        didSet { reloadBundle() }
    }

    private(set) var bundle: Bundle = .main

    var currentLanguage: AppLanguage {
        get { AppLanguage(rawValue: storedLanguage) ?? .russian }
        set {
            storedLanguage = newValue.rawValue
            objectWillChange.send()
        }
    }

    private init() {
        reloadBundle()
    }

    private func reloadBundle() {
        guard
            let path = Bundle.main.path(
                forResource: storedLanguage,
                ofType: "lproj"
            ),
            let langBundle = Bundle(path: path)
        else {
            bundle = .main
            return
        }
        bundle = langBundle
    }

    func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
