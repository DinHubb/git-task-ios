import Foundation

/// Роль пользователя. Права повторяют матрицу из SPEC.md бота.
///
/// Права описаны *вычисляемыми свойствами* (`var ...: Bool { ... }`): экраны спрашивают
/// `role.canAssignOthers`, а не сравнивают `role == .admin || role == .moderator` в десяти местах.
/// Если права поменяются — правим одно место.
nonisolated enum Role: String, CaseIterable, Sendable {
    case admin
    case moderator
    case developer

    var title: String {
        switch self {
        case .admin: "Админ"
        case .moderator: "Модератор"
        case .developer: "Разработчик"
        }
    }

    /// Назначать задачи на других людей (developer — только на себя).
    var canAssignOthers: Bool {
        self != .developer
    }

    /// Видеть все задачи, а не только свои.
    var canSeeAllTasks: Bool {
        self != .developer
    }

    /// Закрывать/переоткрывать задачи и двигать их по доске.
    var canChangeStatus: Bool {
        self != .developer
    }

    /// Удалять задачи.
    var canDeleteTasks: Bool {
        self == .admin
    }

    /// Видеть вкладку статистики.
    var canSeeStats: Bool {
        self != .developer
    }
}
