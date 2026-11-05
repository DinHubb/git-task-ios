import SwiftUI

/// Корневой экран: вкладки внизу.
///
/// У каждой вкладки свой `NavigationStack` — своя история переходов.
/// Ушёл в карточку задачи, переключился на «Профиль», вернулся — карточка на месте.
struct RootView: View {
    /// ViewModel'и вкладок создаются один раз и живут, пока живёт приложение.
    @State private var taskListViewModel: TaskListViewModel

    init(container: AppContainer) {
        _taskListViewModel = State(initialValue: container.makeTaskListViewModel())
    }

    var body: some View {
        TabView {
            Tab("Задачи", systemImage: "checklist") {
                NavigationStack {
                    TaskListView(viewModel: taskListViewModel)
                }
            }

            Tab("Статистика", systemImage: "chart.bar") {
                ComingSoonView(title: "Статистика", module: 7)
            }

            Tab("Профиль", systemImage: "person.crop.circle") {
                ComingSoonView(title: "Профиль", module: 6)
            }
        }
    }
}

/// Заглушка для вкладок, которые появятся в следующих модулях.
private struct ComingSoonView: View {
    let title: String
    let module: Int

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Скоро",
                systemImage: "hammer",
                description: Text("Появится в модуле \(module)")
            )
            .navigationTitle(title)
        }
    }
}

#Preview {
    RootView(container: .mock())
}
