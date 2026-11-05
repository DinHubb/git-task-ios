import Foundation

/// Источник проектов. В GitTaskBot «проект» = репозиторий GitHub организации,
/// поэтому проект — это просто имя репозитория (`String`).
nonisolated protocol ProjectRepository: Sendable {
    func fetchProjects() async throws -> [String]
}
