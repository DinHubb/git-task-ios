import Foundation

/// Данные, которые пользователь вводит при создании задачи.
///
/// Отдельный тип, потому что у новой задачи ещё нет `id`, `issueNumber`, `createdAt` —
/// их назначает сервер (сейчас — mock-репозиторий).
nonisolated struct NewTaskDraft: Hashable, Sendable {
    var repo: String
    var title: String
    var description: String = ""
    var assignee: String?
    var priority: Priority = .medium
    var column: BoardColumn = .todo
    var deadline: Date?
}
