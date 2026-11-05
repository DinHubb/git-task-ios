import Foundation

/// Пользователь приложения.
///
/// `Identifiable` — у значения есть стабильный `id`; SwiftUI использует его в `List`/`ForEach`,
/// чтобы понимать, какая строка какая. `Hashable` — значение можно класть в `Set`
/// и использовать как маршрут навигации.
nonisolated struct User: Identifiable, Hashable, Sendable {
    let id: Int
    var githubUsername: String
    var role: Role
}
