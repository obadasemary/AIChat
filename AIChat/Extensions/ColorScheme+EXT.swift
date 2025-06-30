//
//  File.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.07.2025.
//

import SwiftUI

extension ColorScheme {
    
    var backgroundPrimary: Color {
        self == .dark ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground)
    }
    
    var backgroundSecondary: Color {
        self == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground)
    }
}
