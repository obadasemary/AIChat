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

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    // Helper function to wait for element with better timeout handling
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        if !exists {
            XCTFail("Element \(element) did not appear within \(timeout) seconds", file: file, line: line)
        }
        return exists
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
        let startButton = app.buttons["StartButton"]
        XCTAssert(waitForElement(startButton, timeout: 10))
        startButton.tap()

        // Onboarding Intro View
        let continueButton = app.buttons["ContinueButton"]
        XCTAssert(waitForElement(continueButton, timeout: 5))
        continueButton.tap()
        
        // Onboarding Color View
        let colorCircleElementsQuery = app.otherElements.matching(
            identifier: "ColorCircle"
        )
        // Wait for color circles to appear
        XCTAssert(waitForElement(colorCircleElementsQuery.firstMatch, timeout: 5))
        
        let randomIndex = Int.random(in: 0..<colorCircleElementsQuery.count)
        colorCircleElementsQuery.element(boundBy: randomIndex).tap()
        
        XCTAssert(waitForElement(app.buttons["ContinueButton"], timeout: 3))
        app.buttons["ContinueButton"].tap()
        
        // Onboarding Completed View
        let finishButton = app.buttons["FinishButton"]
        XCTAssert(waitForElement(finishButton, timeout: 5))
        finishButton.tap()
        
        // Explore View
        let exploreNavBar = app.navigationBars["Explore"]
        XCTAssert(waitForElement(exploreNavBar, timeout: 5))
    }
    
    @MainActor
    func testOnboardingFlowWithCommunityFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "ONBOARDING_COMMUNITY_TEST"]
        app.launch()

        // Welcome View
        let startButton = app.buttons["StartButton"]
        XCTAssert(waitForElement(startButton, timeout: 10))
        startButton.tap()

        // Onboarding Intro View
        let continueButton = app.buttons["ContinueButton"]
        XCTAssert(waitForElement(continueButton, timeout: 5))
        continueButton.tap()
        
        // Onboarding Community View
        let communityContinueButton = app.buttons["OnboardingCommunityContinueButton"]
        XCTAssert(waitForElement(communityContinueButton, timeout: 5))
        communityContinueButton.tap()
        
        // Onboarding Color View
        let colorCircleElementsQuery = app.otherElements.matching(
            identifier: "ColorCircle"
        )
        XCTAssert(waitForElement(colorCircleElementsQuery.firstMatch, timeout: 5))
        
        let randomIndex = Int.random(in: 0..<colorCircleElementsQuery.count)
        colorCircleElementsQuery.element(boundBy: randomIndex).tap()
        
        XCTAssert(waitForElement(app.buttons["ContinueButton"], timeout: 3))
        app.buttons["ContinueButton"].tap()
        
        // Onboarding Completed View
        let finishButton = app.buttons["FinishButton"]
        XCTAssert(waitForElement(finishButton, timeout: 5))
        finishButton.tap()
        
        // Explore View
        let exploreNavBar = app.navigationBars["Explore"]
        XCTAssert(waitForElement(exploreNavBar, timeout: 5))
    }
    
    @MainActor
    func testTabBarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN_TEST"]
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        XCTAssert(waitForElement(tabBar, timeout: 10))
        
        let exploreNavBar = app.navigationBars["Explore"]
        XCTAssert(waitForElement(exploreNavBar, timeout: 5))
        
        // Click Hero Cell
        let heroCell = app.collectionViews.scrollViews.otherElements.buttons.firstMatch
        XCTAssert(waitForElement(heroCell, timeout: 5))
        heroCell.tap()
        
        let chatTextField = app.textFields["ChatTextField"]
        XCTAssert(waitForElement(chatTextField, timeout: 5))
        
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssert(waitForElement(backButton, timeout: 3))
        backButton.tap()
        
        XCTAssert(waitForElement(exploreNavBar, timeout: 3))
        
        tabBar.buttons["Chats"].tap()
        let chatsNavBar = app.navigationBars["Chats"]
        XCTAssert(waitForElement(chatsNavBar, timeout: 5))
        
        // Click Hero Cell
        let chatsHeroCell = app.collectionViews.scrollViews.otherElements.buttons.firstMatch
        XCTAssert(waitForElement(chatsHeroCell, timeout: 5))
        chatsHeroCell.tap()
        
        XCTAssert(waitForElement(chatTextField, timeout: 5))
        
        let chatsBackButton = app.navigationBars.buttons.firstMatch
        XCTAssert(waitForElement(chatsBackButton, timeout: 3))
        chatsBackButton.tap()
        
        XCTAssert(waitForElement(chatsNavBar, timeout: 3))
        
        tabBar.buttons["Profile"].tap()
        let profileNavBar = app.navigationBars["Profile"]
        XCTAssert(waitForElement(profileNavBar, timeout: 5))
        
        // Click Hero Cell
        let profileHeroCell = app.collectionViews.buttons.element(boundBy: 1)
        XCTAssert(waitForElement(profileHeroCell, timeout: 5))
        profileHeroCell.tap()
        
        XCTAssert(waitForElement(chatTextField, timeout: 5))
        
        let profileBackButton = app.navigationBars.buttons.firstMatch
        XCTAssert(waitForElement(profileBackButton, timeout: 3))
        profileBackButton.tap()
        
        XCTAssert(waitForElement(profileNavBar, timeout: 3))

        tabBar.buttons["Explore"].tap()
        XCTAssert(waitForElement(exploreNavBar, timeout: 5))
    }
    
    @MainActor
    func testSignOutFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN_TEST"]
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        XCTAssert(waitForElement(tabBar, timeout: 10))
        
        let exploreNavBar = app.navigationBars["Explore"]
        XCTAssert(waitForElement(exploreNavBar, timeout: 5))
        
        tabBar.buttons["Profile"].tap()
        let profileNavBar = app.navigationBars["Profile"]
        XCTAssert(waitForElement(profileNavBar, timeout: 5))
        
        let settingsButton = app.navigationBars["Profile"].buttons["Settings"]
        XCTAssert(waitForElement(settingsButton, timeout: 3))
        settingsButton.tap()
        
        let signOutButton = app.collectionViews.buttons["Sign Out"]
        XCTAssert(waitForElement(signOutButton, timeout: 5))
        signOutButton.tap()
        
        let startButton = app.buttons["StartButton"]
        XCTAssert(waitForElement(startButton, timeout: 5))
    }
    
    @MainActor
    func testCreateAvatarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN_TEST", "STARTSCREEN_CREATE_AVATAR_TEST"]
        app.launch()
        
        let createAvatarNavBar = app.navigationBars["Create Avatar"].firstMatch
        XCTAssert(waitForElement(createAvatarNavBar, timeout: 10))
    }
}
