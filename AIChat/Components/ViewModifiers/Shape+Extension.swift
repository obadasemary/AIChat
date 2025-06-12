//
//  Shape+Extension.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 12.06.2025.
//

import SwiftUI

extension Shape {
    func glassed() -> some View {
        self
            .fill(.ultraThinMaterial)
            .fill(
                .linearGradient(
                    colors: [
                        .primary.opacity(0.08),
                        .primary.opacity(0.05),
                        .primary.opacity(0.01),
                        .clear,
                        .clear,
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .stroke(.primary.opacity(0.2), lineWidth: 0.7)
    }
}
