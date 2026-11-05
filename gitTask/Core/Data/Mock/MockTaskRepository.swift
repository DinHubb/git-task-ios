import Foundation

/// Хранилище задач в памяти — притворяется сервером.
///
/// **Почему `actor`, а не `class`.** Несколько экранов могут одновременно читать и менять задачи.
/// Если два потока одновременно сделают `tasks.append(...)`, массив может испортиться
/// (это называется *гонка данных*). `actor` пропускает к своим данным строго по одному —
/// как очередь в кассу. Поэтому снаружи все его методы вызываются через `await`.
///
/// **Задержка `latency`** имитирует сеть, чтобы на экранах было видно состояние загрузки.
/// В тестах передаём `.zero`, чтобы тесты шли мгновенно.
actor MockTaskRepository: TaskRepository {
    private var tasks: [TaskItem]
    private let latency: Duration
    private var failure: RepositoryError?

    init(
        tasks: [TaskItem] = MockData.tasks(),
        latency: Duration = .milliseconds(500),
        failure: RepositoryError? = nil
    ) {
        self.tasks = tasks
        self.latency = latency
        self.failure = failure
    }

    /// Включить/выключить имитацию ошибки — чтобы посмотреть экран ошибки.
    func simulateFailure(_ error: RepositoryError?) {
        failure = error
    }

    // MARK: - TaskRepository

    func fetchTasks() async throws -> [TaskItem] {
        try await simulateNetwork()
        return tasks
    }

    func create(_ draft: NewTaskDraft, author: String) async throws -> TaskItem {
        try await simulateNetwork()
        let nextIssueNumber = (tasks.filter { $0.repo == draft.repo }.map(\.issueNumber).max() ?? 0) + 1
        let task = TaskItem(
            id: (tasks.map(\.id).max() ?? 0) + 1,
            issueNumber: nextIssueNumber,
            repo: draft.repo,
            title: draft.title,
            description: draft.description,
            author: author,
            assignee: draft.assignee,
            status: .open,
            column: draft.column,
            priority: draft.priority,
            deadline: draft.deadline,
            createdAt: .now
        )
        tasks.append(task)
        return task
    }

    func update(_ task: TaskItem) async throws -> TaskItem {
        try await simulateNetwork()
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            throw RepositoryError.notFound
        }
        tasks[index] = task
        return task
    }

    func delete(id: TaskItem.ID) async throws {
        try await simulateNetwork()
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        tasks.remove(at: index)
    }

    // MARK: - Private

    private func simulateNetwork() async throws {
        if latency > .zero {
            try await Task.sleep(for: latency)
        }
        if let failure {
            throw failure
        }
    }
}
