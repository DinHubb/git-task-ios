import SwiftUI

/// Экран ошибки с кнопкой «Повторить». Один на всё приложение.
///
/// `retry` — *замыкание* (closure): кусок кода, который передают как значение.
/// Компонент не знает, *что* повторять, — это решает тот, кто его показывает.
struct ErrorStateView: View {
    let message: String
    let retry: () async -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Не удалось загрузить", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Повторить") {
                Task { await retry() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ErrorStateView(message: RepositoryError.network.message) {}
}
