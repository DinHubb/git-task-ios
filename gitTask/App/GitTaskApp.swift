import SwiftUI

/// Точка входа приложения.
///
/// `@main` говорит компилятору: «отсюда начинается программа».
/// `App` — протокол SwiftUI, описывающий приложение целиком;
/// `body` возвращает одну или несколько сцен (`Scene`). `WindowGroup` — обычное окно iPhone.
@main
struct GitTaskApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
