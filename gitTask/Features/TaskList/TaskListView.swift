import SwiftUI

/// Экран списка задач.
///
/// View только *показывает* `viewModel.state` и *сообщает* о действиях пользователя
/// (`load()`). Решений «что загрузить» и «как обработать ошибку» здесь нет.
struct TaskListView: View {
    /// Обычный `let`: ViewModel *создаёт и хранит* `RootView` (через `@State`), а этот экран только
    /// пользуется им. `@Observable` работает и так — SwiftUI отследит чтение `viewModel.state`.
    let viewModel: TaskListViewModel

    var body: some View {
        content
            .navigationTitle("Задачи")
            // `.task` запускает async-код, когда экран появился, и *отменяет* его, когда экран исчез.
            .task { await viewModel.loadIfNeeded() }
    }

    /// `@ViewBuilder` разрешает вернуть разные View из разных веток `switch`.
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Загрузка…")
        case let .failed(message):
            ErrorStateView(message: message) { await viewModel.load() }
        case let .loaded(tasks) where tasks.isEmpty:
            ContentUnavailableView(
                "Задач пока нет",
                systemImage: "checklist",
                description: Text("Создайте первую задачу кнопкой «+»")
            )
        case let .loaded(tasks):
            List(tasks) { task in
                TaskRow(task: task)
            }
            .listStyle(.plain)
            // Потянуть список вниз — обновить. SwiftUI сам показывает индикатор, пока `load()` не завершится.
            .refreshable { await viewModel.load() }
        }
    }
}

// Preview для каждого состояния экрана. Переключаются вкладками вверху Canvas.

#Preview("Данные") {
    NavigationStack {
        TaskListView(viewModel: TaskListViewModel(repository: MockTaskRepository()))
    }
}

#Preview("Пусто") {
    NavigationStack {
        TaskListView(viewModel: TaskListViewModel(repository: MockTaskRepository(tasks: [])))
    }
}

#Preview("Ошибка") {
    NavigationStack {
        TaskListView(viewModel: TaskListViewModel(repository: MockTaskRepository(failure: .network)))
    }
}

#Preview("Долгая загрузка") {
    NavigationStack {
        TaskListView(viewModel: TaskListViewModel(repository: MockTaskRepository(latency: .seconds(3600))))
    }
}
