//
//  ColorSchemePreference.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 20.10.2025.
//

import SwiftUI

enum ColorSchemePreference: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Protocol for testability and DI
@MainActor
protocol ColorSchemeManaging: ObservableObject {
    var currentPreference: ColorSchemePreference { get }
    var currentColorScheme: ColorScheme { get }
    func updatePreference(_ preference: ColorSchemePreference)
}

// MARK: - Implementation
@MainActor
final class ColorSchemeManager: ColorSchemeManaging, ObservableObject {
    
    static let shared = ColorSchemeManager()
    
    @AppStorage("color_scheme_preference") private var storedPreference: String = ColorSchemePreference.light.rawValue
    
    @Published private(set) var currentPreference: ColorSchemePreference = .light
    
    private init() {
        // Initialize current preference from stored value after all properties are set
        let initialValue = UserDefaults.standard.string(forKey: "color_scheme_preference")
        self.currentPreference = ColorSchemePreference(rawValue: initialValue ?? "") ?? .light
    }
    
    func updatePreference(_ preference: ColorSchemePreference) {
        currentPreference = preference
        storedPreference = preference.rawValue
    }
    
    var currentColorScheme: ColorScheme {
        currentPreference.colorScheme
    }
}
