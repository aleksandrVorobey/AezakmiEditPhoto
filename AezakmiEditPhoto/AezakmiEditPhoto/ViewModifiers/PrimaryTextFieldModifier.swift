//
//  PrimaryTextFieldModifier.swift
//  AezakmiEditPhoto
//
//  Created by Александр Воробей on 24.04.2025.
//

import SwiftUI

struct PrimaryTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 14)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

extension View {
    func primaryTextFieldStyle() -> some View {
        self.modifier(PrimaryTextFieldModifier())
    }
}
