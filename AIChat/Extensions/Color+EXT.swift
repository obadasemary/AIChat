//
//  Color+EXT.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.05.2025.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
    
    func toHex() -> String? {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return nil
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = (components.count >= 4) ? components[3] : 1.0
        
        let rgb: Int = (Int(red * 255) << 16) | (Int(green * 255) << 8) | Int(blue * 255)
        
        if alpha < 1.0 {
            let alpha = Int(alpha * 255)
            return String(format: "#%02X%06X", alpha, rgb)
        } else {
            return String(format: "#%06X", rgb)
        }
    }
    
    func asHex(alpha: Bool = false) -> String {
        // Convert Color to UIColor
        let uiColor = UIColor(self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alphaValue: CGFloat = 0
        
        // Use guard to ensure all components can be extracted
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alphaValue) else {
            // Return a default color (black or transparent) if unable to extract components
            return alpha ? "#00000000": "#000000"
        }
        
        if alpha {
            // Include alpha component in the hex string
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(Float(alphaValue) * 255),
                lroundf(Float(red) * 255),
                lroundf(Float(green) * 255),
                lroundf(Float(blue) * 255)
            )
        } else {
            // Exclude alpha component from the hex string
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(red) * 255),
                lroundf(Float(green) * 255),
                lroundf(Float(blue) * 255)
            )
        }
    }
}
