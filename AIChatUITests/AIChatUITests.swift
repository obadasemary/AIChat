//
//  AIChatUITests.swift
//  AIChatUITests
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import XCTest

final class AIChatUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        // Welcome View
        app.buttons["StartButton"].tap()

        // Onboarding Intro View
        app.buttons["ContinueButton"].tap()
        
        // Onboarding Color View
        let colorCircleElementsQuery = app.otherElements.matching(
            identifier: "ColorCircle"
        )
        let randomIndex = Int.random(in: 0..<colorCircleElementsQuery.count)
        colorCircleElementsQuery.element(boundBy: randomIndex).tap()
        app.buttons["ContinueButton"].tap()
        
        // Onboarding Completed View
        app.buttons["FinishButton"].tap()
        
        // Explore View
        let exploreExists = app.navigationBars["Explore"].waitForExistence(
            timeout: 1
        )
        XCTAssert(exploreExists)
    }
    
    @MainActor
    func testOnboardingFlowWithCommunityFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "ONBOARDING_COMMUNITY_TEST"]
        app.launch()

        // Welcome View
        app.buttons["StartButton"].tap()

        // Onboarding Intro View
        app.buttons["ContinueButton"].tap()
        
        // Onboarding Community View
        app.buttons["OnboardingCommunityContinueButton"].tap()
        
        // Onboarding Color View
        let colorCircleElementsQuery = app.otherElements.matching(
            identifier: "ColorCircle"
        )
        let randomIndex = Int.random(in: 0..<colorCircleElementsQuery.count)
        colorCircleElementsQuery.element(boundBy: randomIndex).tap()
        app.buttons["ContinueButton"].tap()
        
        // Onboarding Completed View
        app.buttons["FinishButton"].tap()
        
        // Explore View
        let exploreExists = app.navigationBars["Explore"].waitForExistence(
            timeout: 1
        )
        XCTAssert(exploreExists)
    }
    
    @MainActor
    func testTabBarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN_TEST"]
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        
        let exploreExists = app.navigationBars["Explore"].exists
        XCTAssert(exploreExists)
        
        // Click Hero Cell
        app.collectionViews.scrollViews.otherElements.buttons.firstMatch.tap()
        
        let textFieldExists = app.textFields["ChatTextField"].exists
        XCTAssert(textFieldExists)
        
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssert(exploreExists)
        
        tabBar.buttons["Chats"].tap()
        let chatsExists = app.navigationBars["Chats"].exists
        XCTAssert(chatsExists)
        
        // Click Hero Cell
        app.collectionViews.scrollViews.otherElements.buttons.firstMatch.tap()
        XCTAssert(textFieldExists)
        
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssert(chatsExists)
        
        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssert(profileExists)
        
        // Click Hero Cell
        app.collectionViews.buttons.element(boundBy: 1).tap()
        XCTAssert(textFieldExists)
        
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssert(profileExists)

        tabBar.buttons["Explore"].tap()
        XCTAssert(exploreExists)
    }
    
    @MainActor
    func testSignOutFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN_TEST"]
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        
        let exploreExists = app.navigationBars["Explore"].exists
        XCTAssert(exploreExists)
        
        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssert(profileExists)
        
        app.navigationBars["Profile"].buttons["Settings"].tap()
        
        app.collectionViews.buttons["Sign Out"].tap()
        
        let startButtonExists = app.buttons["StartButton"].waitForExistence(
            timeout: 2
        )
        XCTAssert(startButtonExists)
    }
    
    @MainActor
    func testCreateAvatarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN_TEST", "STARTSCREEN_CREATE_AVATAR_TEST"]
        app.launch()
        
        let screenExists = app.navigationBars["Create Avatar"].firstMatch.exists
        XCTAssert(screenExists)
    }
}
