import Foundation

/// Тестовые данные. Одни и те же для приложения, `#Preview` и тестов.
///
/// `enum` без `case` — приём «пространство имён»: создать экземпляр `MockData()` нельзя,
/// можно только обращаться к статическим членам `MockData.users`.
nonisolated enum MockData {
    // MARK: - Пользователи

    static let admin = User(id: 1, githubUsername: "dinhubb", role: .admin)
    static let moderator = User(id: 2, githubUsername: "olga-pm", role: .moderator)
    static let developer = User(id: 3, githubUsername: "alex-dev", role: .developer)
    static let developer2 = User(id: 4, githubUsername: "maria-dev", role: .developer)

    static let users: [User] = [admin, moderator, developer, developer2]

    // MARK: - Проекты (репозитории)

    static let projects = ["gittaskbot", "git-task-ios", "landing", "crm-backend"]

    // MARK: - Задачи

    /// Задачи с датами относительно `now`: «дедлайн через 2 дня» остаётся таким в любой день,
    /// когда открываешь приложение. В тестах `now` фиксированный.
    static func tasks(now: Date = .now, calendar: Calendar = .current) -> [TaskItem] {
        seeds.enumerated().map { index, seed in
            let created = calendar.date(byAdding: .day, value: -seed.createdDaysAgo, to: now) ?? now
            let deadline = seed.deadlineInDays.flatMap { calendar.date(byAdding: .day, value: $0, to: now) }
            return TaskItem(
                id: index + 1,
                issueNumber: index + 101,
                repo: seed.repo,
                title: seed.title,
                description: seed.description,
                author: seed.author,
                assignee: seed.assignee,
                status: seed.column == .done ? .closed : .open,
                column: seed.column,
                priority: seed.priority,
                deadline: deadline,
                createdAt: created
            )
        }
    }

    /// «Заготовка» задачи: только то, что отличается, в компактной форме.
    private struct Seed {
        let repo: String
        let title: String
        var description = ""
        var author = "dinhubb"
        let assignee: String?
        let column: BoardColumn
        let priority: Priority
        var deadlineInDays: Int?
        let createdDaysAgo: Int
    }

    private static let seeds: [Seed] = [
        Seed(
            repo: "gittaskbot",
            title: "Команда /mytasks: пагинация",
            description: "Показывать по 10 задач, кнопки ← →",
            assignee: "alex-dev",
            column: .inProgress,
            priority: .high,
            deadlineInDays: 2,
            createdDaysAgo: 5
        ),
        Seed(
            repo: "gittaskbot",
            title: "Уведомления о новых комментариях",
            assignee: "alex-dev",
            column: .done,
            priority: .medium,
            createdDaysAgo: 20
        ),
        Seed(
            repo: "gittaskbot",
            title: "Починить poller в webhook-режиме",
            description: "poll_github_events не запускается при BOT_MODE=webhook",
            assignee: "maria-dev",
            column: .todo,
            priority: .high,
            deadlineInDays: -1,
            createdDaysAgo: 3
        ),
        Seed(
            repo: "gittaskbot",
            title: "REST API для мобильного клиента",
            author: "olga-pm",
            assignee: "dinhubb",
            column: .backlog,
            priority: .medium,
            createdDaysAgo: 1
        ),
        Seed(
            repo: "gittaskbot",
            title: "Экспорт отчёта в CSV",
            assignee: nil,
            column: .backlog,
            priority: .low,
            createdDaysAgo: 12
        ),
        Seed(
            repo: "git-task-ios",
            title: "Экран списка задач",
            description: "MVVM, LoadState, пустое состояние",
            assignee: "dinhubb",
            column: .todo,
            priority: .high,
            deadlineInDays: 4,
            createdDaysAgo: 0
        ),
        Seed(
            repo: "git-task-ios",
            title: "Карточка задачи",
            assignee: "dinhubb",
            column: .todo,
            priority: .medium,
            deadlineInDays: 7,
            createdDaysAgo: 0
        ),
        Seed(
            repo: "git-task-ios",
            title: "Фильтры и сортировка",
            assignee: "dinhubb",
            column: .backlog,
            priority: .medium,
            createdDaysAgo: 0
        ),
        Seed(
            repo: "git-task-ios",
            title: "Настроить окружение и SwiftLint",
            assignee: "dinhubb",
            column: .done,
            priority: .high,
            createdDaysAgo: 1
        ),
        Seed(
            repo: "landing",
            title: "Новый hero-блок",
            author: "olga-pm",
            assignee: "maria-dev",
            column: .inProgress,
            priority: .medium,
            deadlineInDays: 0,
            createdDaysAgo: 6
        ),
        Seed(
            repo: "landing",
            title: "Оптимизировать картинки",
            assignee: "maria-dev",
            column: .todo,
            priority: .low,
            deadlineInDays: 10,
            createdDaysAgo: 4
        ),
        Seed(
            repo: "landing",
            title: "Форма обратной связи не отправляется в Safari",
            description: "Воспроизводится на iOS 26, кнопка неактивна",
            author: "olga-pm",
            assignee: "alex-dev",
            column: .todo,
            priority: .high,
            deadlineInDays: -3,
            createdDaysAgo: 8
        ),
        Seed(
            repo: "landing",
            title: "Обновить политику конфиденциальности",
            author: "olga-pm",
            assignee: nil,
            column: .done,
            priority: .low,
            createdDaysAgo: 30
        ),
        Seed(
            repo: "crm-backend",
            title: "Миграция на MySQL 8.4",
            assignee: "alex-dev",
            column: .backlog,
            priority: .medium,
            deadlineInDays: 21,
            createdDaysAgo: 9
        ),
        Seed(
            repo: "crm-backend",
            title: "Индекс по полю created_at",
            assignee: "maria-dev",
            column: .inProgress,
            priority: .medium,
            deadlineInDays: 3,
            createdDaysAgo: 2
        ),
        Seed(
            repo: "crm-backend",
            title: "Логи падают при пустом user_id",
            author: "alex-dev",
            assignee: "alex-dev",
            column: .todo,
            priority: .high,
            deadlineInDays: 1,
            createdDaysAgo: 1
        ),
        Seed(
            repo: "crm-backend",
            title: "Документация по API",
            author: "olga-pm",
            assignee: "maria-dev",
            column: .done,
            priority: .low,
            createdDaysAgo: 15
        ),
        Seed(
            repo: "crm-backend",
            title: "Ротация ключей доступа",
            assignee: nil,
            column: .backlog,
            priority: .low,
            createdDaysAgo: 25
        ),
    ]
}
