import XCTest

/// UI-тесты запускают настоящее приложение в симуляторе и «нажимают» на экран как пользователь.
/// Swift Testing пока не умеет UI-тесты, поэтому здесь используется XCTest.
final class AppLaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesAndShowsRootScreen() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["GitTask"].waitForExistence(timeout: 5))
    }
}
