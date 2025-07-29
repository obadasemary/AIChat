//
//  AIChatApp.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI
import SwiftfulUtilities

struct AIChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if Utilities.isUITesting {
                    AppViewForUITesting()
                } else {
                    AppView(
                        viewModel: AppViewModel(
                            appViewUseCase: AppViewUseCase(
                                container: delegate
                                    .dependencies
                                    .container
                            )
                        )
                    )
                }
            }
            .environment(delegate.dependencies.container)
            .environment(delegate.dependencies.logManager)
        }
    }
}
