//
//  ValidatedField.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct ValidatedField<Content: View>: View {
    let error: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            content
        }
        .animation(.easeInOut(duration: 0.2), value: error)
    }
}
