//
//  ButtonStyle.swift
//  Logbook
//
//  Created by Tan Yun ching on 06/05/2022.
//

import SwiftUI

struct SButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 0)
                    .blendMode(.overlay))
            .cornerRadius(6)
            .shadow(color: .secondary.opacity(0.4), radius: 4)
    }
}
