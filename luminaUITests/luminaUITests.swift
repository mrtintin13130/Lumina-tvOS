//
//  luminaUITests.swift
//  luminaUITests
//
//  Created by Martin Thomas on 29/05/2026.
//

import XCTest

final class luminaUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSetupLaunchSmoke() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Sign in to Lumina"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Email"].exists)
        XCTAssertTrue(app.buttons["Change Server"].exists)
    }

    func testSeededHomeSmoke() throws {
        let app = launchSeededApp(argument: "-uiTestingHome")

        XCTAssertTrue(app.staticTexts["UI Test Movie"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Home"].exists)
        XCTAssertTrue(app.buttons["Search"].exists)
        XCTAssertTrue(app.buttons["Profile"].exists)
    }

    func testSeededDetailAndPlaybackEntrySmoke() throws {
        let app = launchSeededApp(argument: "-uiTestingDetail")

        XCTAssertTrue(app.staticTexts["UI Test Movie"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Resume"].exists)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Pilot")).firstMatch.exists)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Director")).firstMatch.exists)
    }

    func testSeededSearchSmoke() throws {
        let app = launchSeededApp(argument: "-uiTestingSearch")

        XCTAssertTrue(app.staticTexts["Search"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["UI Test Movie"].exists)
    }

    func testSeededSettingsAndSignOutDestinationSmoke() throws {
        let settingsApp = launchSeededApp(argument: "-uiTestingSettings")

        XCTAssertTrue(settingsApp.staticTexts["Profile"].waitForExistence(timeout: 8))
        XCTAssertTrue(settingsApp.buttons["Open Apple TV Settings"].exists)
        XCTAssertFalse(settingsApp.staticTexts["Support ID"].exists)
        XCTAssertTrue(settingsApp.buttons["Test Connection"].exists)
        XCTAssertTrue(settingsApp.buttons["Sign Out"].exists)

        let signInApp = launchSeededApp(argument: "-uiTestingSignIn")
        XCTAssertTrue(signInApp.staticTexts["Sign in to Lumina"].waitForExistence(timeout: 8))
        XCTAssertTrue(signInApp.buttons["Change Server"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    private func launchSeededApp(argument: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [argument]
        app.launch()
        return app
    }
}
