import XCTest

/// UI-тесты запускают настоящее приложение в симуляторе и «нажимают» на экран как пользователь.
/// Swift Testing пока не умеет UI-тесты, поэтому здесь используется XCTest.
final class AppLaunchUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesAndShowsTaskList() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Задачи"].waitForExistence(timeout: 5))
        // Mock-репозиторий отвечает через 0,5 с — ждём, пока появится хотя бы одна задача.
        XCTAssertTrue(app.staticTexts["Команда /mytasks: пагинация"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTabsAreVisible() {
        let app = XCUIApplication()
        app.launch()

        for tab in ["Задачи", "Статистика", "Профиль"] {
            XCTAssertTrue(app.tabBars.buttons[tab].waitForExistence(timeout: 5), tab)
        }
    }
}
