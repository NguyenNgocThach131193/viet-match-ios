import XCTest

final class AuthFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func test_loginScreen_displaysAllElements() {
        XCTAssertTrue(app.staticTexts["VietMatch"].exists)
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Mật khẩu"].exists)
        XCTAssertTrue(app.buttons["Đăng nhập"].exists)
    }

    func test_navigateToRegister_displaysRegisterScreen() {
        app.buttons["Đăng ký"].tap()
        XCTAssertTrue(app.staticTexts["Tạo tài khoản"].exists)
    }

    func test_loginWithEmptyFields_showsError() {
        app.buttons["Đăng nhập"].tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 2))
    }
}
