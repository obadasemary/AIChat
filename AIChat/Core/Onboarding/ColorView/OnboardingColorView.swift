//
//  OnboardingColorView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import SwiftUI

struct OnboardingColorView: View {
    
    @State private var selectedColor: Color?
    let profileColors: [Color] = [
        .red,
        .green,
        .orange,
        .blue,
        .mint,
        .yellow,
        .purple,
        .pink,
        .cyan,
        .teal,
        .indigo,
        .brown
    ]
    
    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .safeAreaInset(
            edge: .bottom,
            alignment: .center,
            spacing: 16,
            content: {
                ZStack {
                    if let selectedColor {
                        ctaButton
                            .transition(AnyTransition.move(edge: .bottom))
                    }
                }
                .padding(24)
                .background(Color(uiColor: .systemBackground))
            }
        )
        .animation(.bouncy, value: selectedColor)
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(
                    .flexible(),
                    spacing: 16
                ),
                count: 3
            ),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section {
                    ForEach(profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay(
                                color
                                    .clipShape(Circle())
                                    .padding(selectedColor == color ? 10 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                } header: {
                    Text("Select a profile color")
                        .font(.headline)
                }
                
            }
        )
    }
    
    private var ctaButton: some View {
        NavigationLink {
            OnboardingCompletedView()
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
}
