import SwiftUI

// Внешний вид моделей. Модели в Core/Models не знают про SwiftUI —
// цвета и иконки добавляем здесь через *расширения* (`extension`).
// Расширение дописывает к существующему типу новые свойства, не трогая его исходный файл.

extension Priority {
    var color: Color {
        switch self {
        case .high: .red
        case .medium: .orange
        case .low: .green
        }
    }

    /// Имя иконки SF Symbols.
    var symbolName: String {
        switch self {
        case .high: "exclamationmark.3"
        case .medium: "exclamationmark.2"
        case .low: "exclamationmark"
        }
    }
}

extension BoardColumn {
    var color: Color {
        switch self {
        case .backlog: .gray
        case .todo: .blue
        case .inProgress: .purple
        case .done: .green
        }
    }

    var symbolName: String {
        switch self {
        case .backlog: "tray"
        case .todo: "circle"
        case .inProgress: "circle.lefthalf.filled"
        case .done: "checkmark.circle.fill"
        }
    }
}
