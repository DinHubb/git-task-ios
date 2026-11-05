import Foundation

/// Список проектов не меняется, поэтому хватает `struct` — менять в нём нечего,
/// значит и гонок данных быть не может. `actor` нужен только там, где есть изменяемое состояние.
nonisolated struct MockProjectRepository: ProjectRepository {
    var projects: [String] = MockData.projects

    func fetchProjects() async throws -> [String] {
        projects
    }
}
