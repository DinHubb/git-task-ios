import SwiftUI

/// Маленькая цветная «таблетка» с иконкой и текстом: приоритет, колонка доски.
///
/// Переиспользуемый компонент: один раз сверстали — используем везде.
/// Если дизайнер решит сделать бейджи квадратными, правим одно место.
struct Badge: View {
    let title: String
    let symbolName: String
    let color: Color

    var body: some View {
        Label(title, systemImage: symbolName)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15), in: .capsule)
    }
}

extension Badge {
    init(priority: Priority) {
        self.init(title: priority.title, symbolName: priority.symbolName, color: priority.color)
    }

    init(column: BoardColumn) {
        self.init(title: column.title, symbolName: column.symbolName, color: column.color)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        ForEach(Priority.allCases, id: \.self) { Badge(priority: $0) }
        ForEach(BoardColumn.allCases, id: \.self) { Badge(column: $0) }
    }
    .padding()
}
