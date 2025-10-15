//
//  AIChatUITestsLaunchTests.swift
//  AIChatUITests
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import XCTest

final class AIChatUITestsLaunchTests: XCTestCase {

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for app to fully launch before taking screenshot
        // This helps ensure the screenshot captures the actual UI state
        sleep(2)
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
