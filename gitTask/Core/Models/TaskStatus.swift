import Foundation

/// Статус GitHub Issue: открыта или закрыта.
nonisolated enum TaskStatus: String, CaseIterable, Sendable {
    case open
    case closed

    var title: String {
        switch self {
        case .open: "Открыта"
        case .closed: "Закрыта"
        }
    }
}
