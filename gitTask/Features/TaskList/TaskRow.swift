import SwiftUI

/// Одна строка списка задач.
///
/// View получает только `TaskItem` — никаких репозиториев и ViewModel.
/// Такую View легко показать в Preview и переиспользовать (например, в поиске).
struct TaskRow: View {
    let task: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.title)
                .font(.headline)
                .strikethrough(task.status == .closed)
                .foregroundStyle(task.status == .closed ? .secondary : .primary)

            Text("\(task.repo) #\(task.issueNumber)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Badge(priority: task.priority)
                Badge(column: task.column)
            }

            footer
        }
        .padding(.vertical, 4)
    }

    /// Нижняя строка: ответственный и дедлайн.
    /// Вынесено в отдельное свойство, чтобы `body` оставался коротким и читаемым.
    private var footer: some View {
        HStack {
            Label(task.assignee.map { "@\($0)" } ?? "Не назначена", systemImage: "person")
            Spacer()
            if let deadline = task.deadline {
                Label {
                    // `.relative` — «через 2 дня», «вчера»: формат подбирает система по языку телефона.
                    Text(deadline, format: .relative(presentation: .named))
                } icon: {
                    Image(systemName: task.isOverdue() ? "exclamationmark.triangle.fill" : "calendar")
                }
                .foregroundStyle(task.isOverdue() ? .red : .secondary)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    List(MockData.tasks().prefix(5)) { task in
        TaskRow(task: task)
    }
}
