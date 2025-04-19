//
//  File.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

extension View {
    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.accent)
            .cornerRadius(16)
    }
    
    func tappableBackground() -> some View {
        background(Color.black.opacity(0.001))
    }
    
    func removeListRowFormatting() -> some View {
        self
            .listRowInsets(
                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            )
            .listRowBackground(Color.clear)
    }
    
    func addingGradientBackgroundForText() -> some View {
        background {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        .black.opacity(0),
                        .black.opacity(0.3),
                        .black.opacity(0.4)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
