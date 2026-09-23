//
//  AppLanguage.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 23.09.2026.
//

enum AppLanguage: String, CaseIterable, Identifiable {
    case russian = "ru"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .russian: return "Русский"
        case .english: return "English"
        }
    }
}
