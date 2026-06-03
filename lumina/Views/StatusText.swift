//
//  StatusText.swift
//  lumina
//
//  Created by Martin Thomas on 29/05/2026.
//

import SwiftUI

struct StatusText: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.headline)
                .foregroundStyle(.yellow)
                .accessibilityIdentifier("status-message")
        }
    }
}
