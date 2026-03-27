import XCTest

final class DiscoverFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--authenticated"]
        app.launch()
    }

    func test_discoverTab_exists() {
        let discoverTab = app.tabBars.buttons["Khám phá"]
        XCTAssertTrue(discoverTab.waitForExistence(timeout: 5))
    }

    func test_allTabs_exist() {
        XCTAssertTrue(app.tabBars.buttons["Khám phá"].exists)
        XCTAssertTrue(app.tabBars.buttons["Matches"].exists)
        XCTAssertTrue(app.tabBars.buttons["Chat"].exists)
        XCTAssertTrue(app.tabBars.buttons["Hồ sơ"].exists)
    }
}
