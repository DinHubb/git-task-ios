import Foundation

/// Колонка Kanban-доски GitHub Projects v2.
///
/// Здесь raw value не совпадает с именем случая (`inProgress` ↔ `"In Progress"`),
/// поэтому указываем его явно. Строки — ровно такие, как названия колонок на доске.
nonisolated enum BoardColumn: String, CaseIterable, Sendable {
    case backlog = "Backlog"
    case todo = "Todo"
    case inProgress = "In Progress"
    case done = "Done"

    var title: String {
        switch self {
        case .backlog: "Бэклог"
        case .todo: "К выполнению"
        case .inProgress: "В работе"
        case .done: "Готово"
        }
    }

    /// Колонки, которые можно выбрать при создании задачи (как в боте: Todo или Backlog).
    static let creatable: [BoardColumn] = [.todo, .backlog]
}
