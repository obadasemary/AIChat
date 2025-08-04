//
//  AppViewForUITesting.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import SwiftUI

struct AppViewForUITesting: View {
    
    @Environment(AppBuilder.self) private var appBuilder
    @Environment(CreateAvatarBuilder.self) private var createAvatarBuilder
    
    private var startOnCreateAvatar: Bool {
        ProcessInfo
            .processInfo
            .arguments
            .contains("STARTSCREEN_CREATE_AVATAR_TEST")
    }
    
    var body: some View {
        if startOnCreateAvatar {
            createAvatarBuilder.buildCreateAvatarView()
        } else {
            appBuilder.buildAppView()
        }
    }
}
