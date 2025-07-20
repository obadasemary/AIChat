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
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"] // SIGNED_IN
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
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
