import Testing
@testable import gitTask

struct EnumTests {
    @Test("Raw value совпадают со строками бэкенда GitTaskBot")
    func rawValuesMatchBackend() {
        #expect(Priority.allCases.map(\.rawValue) == ["high", "medium", "low"])
        #expect(TaskStatus.allCases.map(\.rawValue) == ["open", "closed"])
        #expect(BoardColumn.allCases.map(\.rawValue) == ["Backlog", "Todo", "In Progress", "Done"])
        #expect(Role.allCases.map(\.rawValue) == ["admin", "moderator", "developer"])
    }

    @Test("Вес приоритета убывает: high > medium > low")
    func priorityWeightsAreOrdered() {
        #expect(Priority.high.weight > Priority.medium.weight)
        #expect(Priority.medium.weight > Priority.low.weight)
    }

    @Test("Матрица прав из SPEC.md", arguments: Role.allCases)
    func rolePermissions(role: Role) {
        let isManager = role != .developer
        #expect(role.canAssignOthers == isManager)
        #expect(role.canSeeAllTasks == isManager)
        #expect(role.canChangeStatus == isManager)
        #expect(role.canSeeStats == isManager)
        #expect(role.canDeleteTasks == (role == .admin))
    }
}
