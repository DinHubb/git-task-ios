import Foundation

/// Приоритет задачи.
///
/// `String` после двоеточия — это *raw value*: у каждого случая есть строковое значение
/// (`Priority.high.rawValue == "high"`). Строки совпадают с тем, что хранит бэкенд GitTaskBot,
/// поэтому позже JSON распарсится без ручного перевода.
nonisolated enum Priority: String, CaseIterable, Sendable {
    case high
    case medium
    case low

    /// Название для интерфейса.
    var title: String {
        switch self {
        case .high: "Высокий"
        case .medium: "Средний"
        case .low: "Низкий"
        }
    }

    /// Вес для сортировки «по важности»: чем больше, тем важнее. Как `_PRIORITY_SCORE` в боте.
    var weight: Int {
        switch self {
        case .high: 3
        case .medium: 2
        case .low: 1
        }
    }
}
