import Foundation

/// Ошибки слоя данных. Экран не знает, откуда пришла ошибка (mock, сеть, база) —
/// он получает одну из этих понятных причин и показывает `message`.
nonisolated enum RepositoryError: Error, Equatable, Sendable {
    case notFound
    case network
    case forbidden

    var message: String {
        switch self {
        case .notFound: "Задача не найдена"
        case .network: "Нет связи с сервером. Попробуйте ещё раз"
        case .forbidden: "Недостаточно прав"
        }
    }
}
