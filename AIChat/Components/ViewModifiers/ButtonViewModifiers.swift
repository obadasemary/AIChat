//
//  ButtonViewModifiers.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 09.04.2025.
//

import SwiftUI

struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                configuration.isPressed ? Color.accent.opacity(0.5) : Color.clear.opacity(0)
            }
            .animation(.smooth, value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
}

enum ButtonStyleOption {
    case press
    case highlight
    case plain
}

extension View {
    
    @ViewBuilder
    func anyButton(
        _ option: ButtonStyleOption = .plain,
        action: @escaping () -> Void
    ) -> some View {
        switch option {
        case .press:
            pressableButton(action: action)
        case .highlight:
            highlightButton(action: action)
        case .plain:
            plainButton(action: action)
        }
    }
    
    private func highlightButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(HighlightButtonStyle())
    }
    
    private func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }
    
    private func plainButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    Text("Hello, World From Highlight!")
        .padding()
        .frame(maxWidth: .infinity)
        .tappableBackground()
        .anyButton(.highlight) {
            
        }
        .padding()
    
    Text("Hello, World From Pressable!")
        .padding()
        .frame(maxWidth: .infinity)
        .callToActionButton()
        .anyButton(.press) {
            
        }
        .padding()
    
    Text("Hello, World From Plain!")
        .padding()
        .frame(maxWidth: .infinity)
        .callToActionButton()
        .anyButton {
            
        }
        .padding()
}
