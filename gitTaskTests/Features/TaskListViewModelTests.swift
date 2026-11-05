import Foundation
import Testing
@testable import gitTask

/// ViewModel работает на главном потоке (`MainActor`), поэтому и тесты — тоже.
@MainActor
struct TaskListViewModelTests {
    let tasks = MockData.tasks()

    @Test("Сразу после создания — idle, ничего не загружено")
    func initialStateIsIdle() {
        let viewModel = TaskListViewModel(repository: StubTaskRepository(result: .success([])))
        #expect(viewModel.state == .idle)
    }

    @Test("Успешная загрузка → loaded с задачами")
    func loadSuccess() async {
        let viewModel = TaskListViewModel(repository: StubTaskRepository(result: .success(tasks)))

        await viewModel.load()

        #expect(viewModel.state == .loaded(tasks))
    }

    @Test("Ошибка репозитория → failed с понятным текстом")
    func loadFailure() async {
        let viewModel = TaskListViewModel(
            repository: StubTaskRepository(result: .failure(RepositoryError.network))
        )

        await viewModel.load()

        #expect(viewModel.state == .failed(message: RepositoryError.network.message))
    }

    @Test("Неизвестная ошибка → общий текст, а не технические детали")
    func unknownErrorHasGenericMessage() async {
        struct SomeError: Error {}
        let viewModel = TaskListViewModel(repository: StubTaskRepository(result: .failure(SomeError())))

        await viewModel.load()

        guard case let .failed(message) = viewModel.state else {
            Issue.record("Ожидали failed, получили \(viewModel.state)")
            return
        }
        #expect(message == "Что-то пошло не так. Попробуйте ещё раз")
    }

    @Test("«Повторить» после ошибки загружает данные")
    func retryAfterFailure() async {
        let repository = StubTaskRepository(result: .failure(RepositoryError.network))
        let viewModel = TaskListViewModel(repository: repository)
        await viewModel.load()

        await repository.setResult(.success(tasks))
        await viewModel.load()

        #expect(viewModel.state == .loaded(tasks))
    }

    @Test("loadIfNeeded загружает один раз — возврат на вкладку не перезагружает")
    func loadIfNeededLoadsOnce() async {
        let repository = StubTaskRepository(result: .success(tasks))
        let viewModel = TaskListViewModel(repository: repository)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.fetchCount == 1)
    }

    @Test("Ошибка при обновлении заменяет старые данные сообщением об ошибке")
    func refreshFailureShowsError() async {
        let repository = StubTaskRepository(result: .success(tasks))
        let viewModel = TaskListViewModel(repository: repository)
        await viewModel.load()

        await repository.setResult(.failure(RepositoryError.network))
        await viewModel.load()

        #expect(viewModel.state == .failed(message: RepositoryError.network.message))
    }

    @Test("Отмена загрузки (ушли с экрана) — не ошибка, возвращаемся в idle")
    func cancellationIsNotAnError() async {
        let viewModel = TaskListViewModel(
            repository: StubTaskRepository(result: .failure(CancellationError()))
        )

        await viewModel.load()

        #expect(viewModel.state == .idle)
    }
}
