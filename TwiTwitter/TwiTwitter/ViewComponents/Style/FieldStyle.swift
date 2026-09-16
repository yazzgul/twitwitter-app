//
//  FieldStyle.swift
//  TwiTwitter
//
//  Created by Язгуль Хасаншина on 16.09.2026.
//

import SwiftUI

struct FieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
// чтобы упростить дальнейшую запись
extension View {
    func authFieldStyle() -> some View {
        modifier(FieldStyle())
    }
}
