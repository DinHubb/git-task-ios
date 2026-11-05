import Foundation

/// Контейнер зависимостей (DI — Dependency Injection, «внедрение зависимостей»).
///
/// **Единственное место**, где решается, какие реализации использует приложение.
/// Сейчас — mock. Когда появится бэкенд, добавим `static func live()` с API-репозиториями
/// и поменяем одну строку в `GitTaskApp`. Экраны и ViewModel'и об этом не узнают.
///
/// Экраны не создают репозитории сами — они получают готовые через `make...ViewModel()`.
struct AppContainer {
    let taskRepository: any TaskRepository
    let userRepository: any UserRepository
    let projectRepository: any ProjectRepository

    static func mock() -> AppContainer {
        AppContainer(
            taskRepository: MockTaskRepository(),
            userRepository: MockUserRepository(),
            projectRepository: MockProjectRepository()
        )
    }

    // MARK: - Фабрики ViewModel

    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(repository: taskRepository)
    }
}
