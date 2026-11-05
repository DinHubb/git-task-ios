import Foundation
import Testing
@testable import gitTask

/// Учебный пример Swift Testing. В модуле 1 заменим на настоящие тесты моделей.
///
/// - `@Test` помечает функцию как тест (не нужно наследоваться от `XCTestCase`).
/// - `#expect(...)` — проверка; при провале тест продолжает работу и показывает значения.
/// - `#require(...)` — проверка, после провала которой тест останавливается.
struct ExampleTests {
    @Test("Сложение работает")
    func addition() {
        #expect(2 + 2 == 4)
    }

    @Test("Параметризованный тест: один тест — много входных данных", arguments: ["", "  ", "\n"])
    func blankStringsAreEmptyAfterTrimming(input: String) {
        #expect(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}
