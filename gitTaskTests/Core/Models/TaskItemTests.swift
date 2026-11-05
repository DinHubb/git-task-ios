import Foundation
import Testing
@testable import gitTask

struct TaskItemTests {
    /// Фиксированная «сейчас» — тест даёт одинаковый результат в любой день.
    let now = Date(timeIntervalSince1970: 1_800_000_000)

    func makeTask(status: TaskStatus = .open, deadline: Date?) -> TaskItem {
        TaskItem(
            id: 1, issueNumber: 1, repo: "repo", title: "Задача", description: "",
            author: "a", assignee: nil, status: status, column: .todo, priority: .medium,
            deadline: deadline, createdAt: now
        )
    }

    @Test("Открытая задача с прошедшим дедлайном — просрочена")
    func overdueWhenDeadlinePassed() {
        let task = makeTask(deadline: now.addingTimeInterval(-60))
        #expect(task.isOverdue(now: now))
    }

    @Test("Дедлайн в будущем — не просрочена")
    func notOverdueWhenDeadlineInFuture() {
        let task = makeTask(deadline: now.addingTimeInterval(60))
        #expect(!task.isOverdue(now: now))
    }

    @Test("Без дедлайна — не просрочена")
    func notOverdueWithoutDeadline() {
        #expect(!makeTask(deadline: nil).isOverdue(now: now))
    }

    @Test("Закрытая задача не бывает просроченной")
    func closedTaskIsNeverOverdue() {
        let task = makeTask(status: .closed, deadline: now.addingTimeInterval(-60))
        #expect(!task.isOverdue(now: now))
    }
}
