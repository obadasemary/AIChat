//
//  AppViewForUITesting.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import SwiftUI

struct AppViewForUITesting: View {
    
    private var startOnCreateAvatar: Bool {
        ProcessInfo
            .processInfo
            .arguments
            .contains("STARTSCREEN_CREATE_AVATAR_TEST")
    }
    
    var body: some View {
        if startOnCreateAvatar {
            CreateAvatarView()
        } else {
            AppView()
        }
    }
}
