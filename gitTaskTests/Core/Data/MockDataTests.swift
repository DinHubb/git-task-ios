import Testing
@testable import gitTask

struct MockDataTests {
    let tasks = MockData.tasks()

    @Test("id задач уникальны")
    func idsAreUnique() {
        #expect(Set(tasks.map(\.id)).count == tasks.count)
    }

    @Test("Задачи в колонке Done закрыты, остальные открыты")
    func statusMatchesColumn() {
        for task in tasks {
            #expect((task.column == .done) == (task.status == .closed), "\(task.title)")
        }
    }

    @Test("Каждая задача ссылается на существующий проект и пользователя")
    func referencesAreValid() {
        let usernames = Set(MockData.users.map(\.githubUsername))
        for task in tasks {
            #expect(MockData.projects.contains(task.repo))
            #expect(usernames.contains(task.author))
            if let assignee = task.assignee {
                #expect(usernames.contains(assignee))
            }
        }
    }

    @Test("В данных есть все колонки и хотя бы одна просроченная задача — экранам есть что показать")
    func coversAllCases() {
        #expect(Set(tasks.map(\.column)) == Set(BoardColumn.allCases))
        #expect(tasks.contains { $0.isOverdue() })
    }
}
