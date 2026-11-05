import Foundation

/// Задача — GitHub Issue с данными доски.
///
/// Назвали `TaskItem`, а не `Task`: `Task` уже занят Swift Concurrency (`Task { await ... }`).
///
/// Это `struct` — *тип-значение*: при присваивании `var copy = task` создаётся независимая копия.
/// Изменил копию — оригинал не поменялся. Для данных это безопаснее, чем `class`,
/// где обе переменные указывали бы на один объект.
nonisolated struct TaskItem: Identifiable, Hashable, Sendable {
    let id: Int
    var issueNumber: Int
    var repo: String
    var title: String
    var description: String
    var author: String
    var assignee: String?
    var status: TaskStatus
    var column: BoardColumn
    var priority: Priority
    var deadline: Date?
    var createdAt: Date

    /// Просрочена ли задача на момент `now`.
    ///
    /// `now` передаётся параметром, а не берётся внутри как `Date()`:
    /// так тест может подставить любую дату и результат всегда предсказуем.
    func isOverdue(now: Date = .now) -> Bool {
        guard status == .open, let deadline else { return false }
        return deadline < now
    }
}
