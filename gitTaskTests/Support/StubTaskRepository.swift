import Foundation
@testable import gitTask

/// Тестовый двойник (test double) репозитория: отдаёт заранее заданный результат
/// и считает, сколько раз его вызвали. Нужен только тестам — поэтому живёт в тестовом таргете.
///
/// Чем отличается от `MockTaskRepository`: mock — «правдоподобный сервер» для приложения и Preview,
/// stub — максимально простая подставка, которой тест управляет полностью.
actor StubTaskRepository {
    private(set) var fetchCount = 0
    private var result: Result<[TaskItem], any Error>

    init(result: Result<[TaskItem], any Error>) {
        self.result = result
    }

    func setResult(_ result: Result<[TaskItem], any Error>) {
        self.result = result
    }
}

/// Соответствие протоколу — в расширении, а не в объявлении `actor StubTaskRepository: TaskRepository`.
/// Иначе компилятор переносит `nonisolated` с протокола на сам actor и выдаёт ошибку
/// («'nonisolated' modifier cannot be applied to this declaration»). Подробнее — docs/modules/02-task-list.md.
extension StubTaskRepository: TaskRepository {
    func fetchTasks() async throws -> [TaskItem] {
        fetchCount += 1
        return try result.get()
    }

    func create(_: NewTaskDraft, author _: String) async throws -> TaskItem {
        fatalError("Не используется в этих тестах")
    }

    func update(_: TaskItem) async throws -> TaskItem {
        fatalError("Не используется в этих тестах")
    }

    func delete(id _: TaskItem.ID) async throws {
        fatalError("Не используется в этих тестах")
    }
}
