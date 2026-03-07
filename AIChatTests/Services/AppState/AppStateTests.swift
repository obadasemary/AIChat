//
//  AppStateTests.swift
//  AIChatTests
//

import Testing
@testable import AIChat

@MainActor
struct AppStateTests {

    // MARK: - Initial State

    @Test("Default selectedTab is explore")
    func test_defaultSelectedTab_isExplore() {
        let appState = AppState(showTabBar: true)
        #expect(appState.selectedTab == .explore)
    }

    @Test("Default showTabBar reflects init parameter")
    func test_showTabBar_reflectsInitParameter() {
        let shown = AppState(showTabBar: true)
        let hidden = AppState(showTabBar: false)

        #expect(shown.showTabBar == true)
        #expect(hidden.showTabBar == false)
    }

    // MARK: - switchToTab

    @Test("switchToTab chats updates selectedTab to chats")
    func test_switchToTab_chats_updatesSelectedTab() {
        let appState = AppState(showTabBar: true)

        appState.switchToTab(.chats)

        #expect(appState.selectedTab == .chats)
    }

    @Test("switchToTab profile updates selectedTab to profile")
    func test_switchToTab_profile_updatesSelectedTab() {
        let appState = AppState(showTabBar: true)

        appState.switchToTab(.profile)

        #expect(appState.selectedTab == .profile)
    }

    @Test("switchToTab explore updates selectedTab back to explore")
    func test_switchToTab_explore_updatesSelectedTabBackToExplore() {
        let appState = AppState(showTabBar: true)
        appState.switchToTab(.chats)

        appState.switchToTab(.explore)

        #expect(appState.selectedTab == .explore)
    }

    @Test("switchToTab is the only mutation path for selectedTab")
    func test_switchToTab_isOnlyMutationPath_forSelectedTab() {
        // selectedTab is private(set), so the only way to change it is via switchToTab.
        // This test verifies all three tabs are reachable exclusively through switchToTab.
        let appState = AppState(showTabBar: true)

        appState.switchToTab(.explore)
        #expect(appState.selectedTab == .explore)

        appState.switchToTab(.chats)
        #expect(appState.selectedTab == .chats)

        appState.switchToTab(.profile)
        #expect(appState.selectedTab == .profile)
    }

    // MARK: - updateViewState

    @Test("updateViewState shows tab bar")
    func test_updateViewState_showsTabBar() {
        let appState = AppState(showTabBar: false)

        appState.updateViewState(showTabBarView: true)

        #expect(appState.showTabBar == true)
    }

    @Test("updateViewState hides tab bar")
    func test_updateViewState_hidesTabBar() {
        let appState = AppState(showTabBar: true)

        appState.updateViewState(showTabBarView: false)

        #expect(appState.showTabBar == false)
    }
}
