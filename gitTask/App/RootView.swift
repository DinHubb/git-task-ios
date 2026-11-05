import SwiftUI

/// Корневой экран. Пока это заглушка — в модуле 2 здесь появится `TabView` с вкладками.
struct RootView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Скоро здесь будут задачи",
                systemImage: "checklist",
                description: Text("Модуль 0: окружение настроено")
            )
            .navigationTitle("GitTask")
        }
    }
}

#Preview {
    RootView()
}
