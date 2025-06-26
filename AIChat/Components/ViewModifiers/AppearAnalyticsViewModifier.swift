//
//  AppearAnalyticsViewModifier.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 26.06.2025.
//

import SwiftUI

struct AppearAnalyticsViewModifier: ViewModifier {
    
    @Environment(LogManager.self) private var logManager
    let name: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                logManager.trackScreen(event: Event.appear(name: name))
            }
            .onDisappear {
                logManager.trackEvent(event: Event.disappear(name: name))
            }
    }
    
    enum Event: LoggableEvent {
        case appear(name: String)
        case disappear(name: String)
        
        var eventName: String {
            switch self {
            case .appear(name: let name):
                "\(name)_Appear"
            case .disappear(name: let name):
                "\(name)_Disappear"
            }
        }

        var parameters: [String : Any]? {
            nil
        }

        var type: LogType {
            .analytic
        }
    }
}

extension View {
    public func screenAppearAnalytics(name: String) -> some View {
        modifier(AppearAnalyticsViewModifier(name: name))
    }
}

extension View {
    static var screenName: String {
        String(describing: Self.self)
    }
}
