import Foundation
import Testing
@testable import gitTask

struct MockTaskRepositoryTests {
    /// Каждый тест получает новый экземпляр структуры, а значит — свежий репозиторий.
    /// Тесты не влияют друг на друга. `latency: .zero` — без искусственной задержки.
    let repository = MockTaskRepository(latency: .zero)

    @Test("fetchTasks возвращает все тестовые задачи")
    func fetchReturnsAllTasks() async throws {
        let tasks = try await repository.fetchTasks()
        #expect(tasks.count == MockData.tasks().count)
    }

    @Test("create назначает новый id и следующий номер issue в этом репозитории")
    func createAssignsIdentifiers() async throws {
        let before = try await repository.fetchTasks()
        let draft = NewTaskDraft(repo: "landing", title: "Новая задача", priority: .high)

        let created = try await repository.create(draft, author: "dinhubb")

        let maxId = try #require(before.map(\.id).max())
        let maxLandingIssue = try #require(before.filter { $0.repo == "landing" }.map(\.issueNumber).max())
        #expect(created.id == maxId + 1)
        #expect(created.issueNumber == maxLandingIssue + 1)
        #expect(created.status == .open)
        #expect(created.author == "dinhubb")
        #expect(try await repository.fetchTasks().count == before.count + 1)
    }

    @Test("update сохраняет изменения")
    func updatePersistsChanges() async throws {
        var task = try #require(try await repository.fetchTasks().first)
        task.title = "Изменённый заголовок"

        _ = try await repository.update(task)

        let reloaded = try await repository.fetchTasks().first { $0.id == task.id }
        #expect(reloaded?.title == "Изменённый заголовок")
    }

    @Test("update несуществующей задачи бросает notFound")
    func updateMissingThrows() async throws {
        let missing = TaskItem(
            id: 9999, issueNumber: 1, repo: "landing", title: "", description: "", author: "",
            assignee: nil, status: .open, column: .todo, priority: .low, deadline: nil, createdAt: .now
        )
        await #expect(throws: RepositoryError.notFound) {
            try await repository.update(missing)
        }
    }

    @Test("delete удаляет задачу")
    func deleteRemovesTask() async throws {
        let id = try #require(try await repository.fetchTasks().first?.id)

        try await repository.delete(id: id)

        #expect(try await repository.fetchTasks().contains { $0.id == id } == false)
    }

    @Test("Имитация ошибки: методы бросают заданную ошибку, после сброса снова работают")
    func simulatedFailure() async throws {
        await repository.simulateFailure(.network)
        await #expect(throws: RepositoryError.network) {
            try await repository.fetchTasks()
        }

        await repository.simulateFailure(nil)
        #expect(try await repository.fetchTasks().isEmpty == false)
    }
}
