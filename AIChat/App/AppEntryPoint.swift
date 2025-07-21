//
//  AppEntryPoint.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import SwiftUI
import SwiftfulUtilities

@main
struct AppEntryPoint {
    
    static func main() {
        if Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatApp.main()
        }
    }
}
