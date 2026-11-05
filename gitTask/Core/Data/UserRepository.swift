import Foundation

/// Источник пользователей: кто сейчас вошёл и кто есть в команде.
nonisolated protocol UserRepository: Sendable {
    func currentUser() async throws -> User
    func allUsers() async throws -> [User]
}
