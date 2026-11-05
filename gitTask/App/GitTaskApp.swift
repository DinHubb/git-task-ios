import SwiftUI

/// Точка входа приложения.
///
/// `@main` говорит компилятору: «отсюда начинается программа».
/// `App` — протокол SwiftUI, описывающий приложение целиком;
/// `body` возвращает одну или несколько сцен (`Scene`). `WindowGroup` — обычное окно iPhone.
@main
struct GitTaskApp: App {
    /// Здесь выбирается источник данных для всего приложения.
    private let container = AppContainer.mock()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
