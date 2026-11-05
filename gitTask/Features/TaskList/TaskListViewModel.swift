import Foundation
import Observation

/// Логика экрана списка задач.
///
/// **`@Observable`** — макрос Observation. SwiftUI запоминает, какие свойства View прочитала
/// в `body`, и перерисовывает её, только когда меняются *именно они*.
///
/// **`final class`, а не `struct`.** ViewModel — один общий объект, который живёт, пока открыт экран;
/// View (`struct`) пересоздаётся много раз, но ссылается на один и тот же ViewModel.
///
/// **Главный поток.** Класс (по умолчанию в проекте) работает на `MainActor`: свойства, которые
/// читает UI, меняются только с главного потока — как того требует iOS.
@Observable
final class TaskListViewModel {
    /// `private(set)` — читать могут все, менять — только сам ViewModel.
    /// View не может «случайно» поставить `.loading`.
    private(set) var state: LoadState<[TaskItem]> = .idle

    /// `any TaskRepository` — «любой тип, который выполняет контракт TaskRepository».
    /// ViewModel не знает, mock это или сеть.
    private let repository: any TaskRepository

    init(repository: any TaskRepository) {
        self.repository = repository
    }

    /// Загрузить при первом показе экрана. Повторный показ (возврат на вкладку) данные не перезагружает.
    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    /// Загрузить (или перезагрузить) задачи.
    ///
    /// При обновлении (pull-to-refresh) уже показанные задачи остаются на экране —
    /// у `List` есть свой индикатор обновления, мигать «пустым» экраном не нужно.
    func load() async {
        if state.value == nil {
            state = .loading
        }
        do {
            let tasks = try await repository.fetchTasks()
            state = .loaded(tasks)
        } catch is CancellationError {
            // Пользователь ушёл с экрана, и SwiftUI отменил загрузку. Это не ошибка —
            // показывать «Не удалось загрузить» не нужно. Вернёмся в idle, чтобы загрузить при возврате.
            if state.value == nil {
                state = .idle
            }
        } catch {
            state = .failed(message: Self.message(for: error))
        }
    }

    private static func message(for error: any Error) -> String {
        (error as? RepositoryError)?.message ?? "Что-то пошло не так. Попробуйте ещё раз"
    }
}
