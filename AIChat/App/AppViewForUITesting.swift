//
//  AppViewForUITesting.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.07.2025.
//

import SwiftUI
import SUIRouting

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
            RouterView { router in
                createAvatarBuilder.buildCreateAvatarView(router: router)
            }
        } else {
            appBuilder.buildAppView()
        }
    }
}
