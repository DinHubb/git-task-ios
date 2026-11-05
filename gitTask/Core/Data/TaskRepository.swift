import Foundation

/// Источник задач.
///
/// Протокол — это *контракт*: «тот, кто им называется, умеет вот это». Как именно — не важно.
/// Сейчас контракт выполняет `MockTaskRepository` (данные в памяти),
/// потом — `APITaskRepository` (бэкенд). ViewModel'и знают только про протокол,
/// поэтому замена одной реализации на другую их не затронет.
///
/// - `async` — метод может «подождать» (сеть, диск), не блокируя интерфейс.
/// - `throws` — метод может завершиться ошибкой; вызывающий обязан её обработать (`try`).
/// - `Sendable` — объект безопасно передавать между потоками.
nonisolated protocol TaskRepository: Sendable {
    func fetchTasks() async throws -> [TaskItem]
    func create(_ draft: NewTaskDraft, author: String) async throws -> TaskItem
    func update(_ task: TaskItem) async throws -> TaskItem
    func delete(id: TaskItem.ID) async throws
}
