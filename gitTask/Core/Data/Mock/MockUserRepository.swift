import Foundation

/// Пользователи в памяти. `current` можно сменить, чтобы посмотреть интерфейс глазами другой роли.
actor MockUserRepository: UserRepository {
    private var current: User
    private let users: [User]

    init(current: User = MockData.admin, users: [User] = MockData.users) {
        self.current = current
        self.users = users
    }

    func switchUser(to user: User) {
        current = user
    }

    func currentUser() async throws -> User {
        current
    }

    func allUsers() async throws -> [User] {
        users
    }
}
