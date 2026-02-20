//
//  AppState.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

enum AppTab: Hashable {
    case explore
    case chats
    case profile
}

@Observable
class AppState {
    
    private(set) var showTabBar: Bool {
        didSet {
            UserDefaults.showTabBarView = showTabBar
        }
    }
    
    var selectedTab: AppTab = .explore
    
    init(showTabBar: Bool = UserDefaults.showTabBarView) {
        self.showTabBar = showTabBar
    }
    
    func updateViewState(showTabBarView: Bool) {
        showTabBar = showTabBarView
    }
    
    func switchToTab(_ tab: AppTab) {
        selectedTab = tab
    }
}

fileprivate extension UserDefaults {
    
    private struct Keys {
        static let showTabBarView = "showTabBarView"
    }
    
    static var showTabBarView: Bool {
        get {
            standard.bool(forKey: Keys.showTabBarView)
        } set {
            standard.set(newValue, forKey: Keys.showTabBarView)
        }
    }
}
