# Модуль 1 — Модели и mock-данные

**Итог:** описаны все данные приложения (задача, пользователь, роли, приоритеты, колонки доски),
контракты слоя данных (протоколы репозиториев) и их mock-реализации с тестовыми данными.
Экранов пока нет — это «фундамент», на который встанут модули 2–7.

---

## Что сделано

```
gitTask/Core/
├── Models/                      # ЧТО за данные
│   ├── TaskItem.swift           # задача (struct)
│   ├── NewTaskDraft.swift       # данные формы создания задачи
│   ├── User.swift               # пользователь
│   ├── Role.swift               # admin / moderator / developer + права
│   ├── Priority.swift           # high / medium / low
│   ├── TaskStatus.swift         # open / closed
│   └── BoardColumn.swift        # Backlog / Todo / In Progress / Done
└── Data/                        # ОТКУДА данные
    ├── TaskRepository.swift     # протокол: получить/создать/изменить/удалить задачи
    ├── UserRepository.swift     # протокол: текущий пользователь, все пользователи
    ├── ProjectRepository.swift  # протокол: список проектов (= репозиториев GitHub)
    ├── RepositoryError.swift    # понятные ошибки: notFound / network / forbidden
    └── Mock/
        ├── MockData.swift            # 4 пользователя, 4 проекта, 18 задач
        ├── MockTaskRepository.swift  # actor, задержка «сети», имитация ошибок
        ├── MockUserRepository.swift  # actor, можно сменить текущего пользователя
        └── MockProjectRepository.swift

gitTaskTests/Core/               # 19 unit-тестов
├── Models/TaskItemTests.swift, EnumTests.swift
└── Data/MockDataTests.swift, MockTaskRepositoryTests.swift
```

**Связь с ботом.** Строки в `rawValue` совпадают с тем, что хранит GitTaskBot
(`"high"`, `"In Progress"`, `"admin"`…), а права ролей — с матрицей из `SPEC.md`.
Тест `rawValuesMatchBackend` следит, чтобы это не сломалось.

**Слои не смешиваются:** в `Core/Models` и `Core/Data` нет `import SwiftUI`. Модели не знают,
как они выглядят на экране. Цвета и иконки появятся в `DesignSystem` в модуле 2.

---

## Концепции

### `struct` и `class`: значение и ссылка
```swift
var a = task          // struct: a — независимая копия
a.title = "Новое"     // task.title не изменился
```
У `class` обе переменные указывали бы на **один** объект, и изменение через `a` было бы видно через `task`.
Для данных почти всегда берут `struct`: так нет неожиданных изменений «где-то там».
`class` нужен, когда нужен *один общий объект с идентичностью*, например ViewModel в модуле 2.

### `enum` с raw value и вычисляемыми свойствами
```swift
enum BoardColumn: String, CaseIterable {
    case backlog = "Backlog"
    case inProgress = "In Progress"       // raw value можно задать явно
    var title: String { switch self { … } }  // вычисляемое свойство
}
BoardColumn(rawValue: "In Progress")      // → .inProgress (или nil, если строки нет)
BoardColumn.allCases                      // все случаи — благодаря CaseIterable
```
`switch` по `enum` должен перечислить **все** случаи. Если добавишь `case critical` в `Priority`,
компилятор покажет каждое место, где его нужно обработать. Это главная сила `enum`.

### Протоколы — контракт
```swift
protocol TaskRepository {
    func fetchTasks() async throws -> [TaskItem]
}
actor MockTaskRepository: TaskRepository { … }   // выполняет контракт
// потом: struct APITaskRepository: TaskRepository { … }
```
Код, которому нужны задачи, просит «что-нибудь, что умеет `TaskRepository`», и ему не важно, mock это или сеть.
На этом держится вся архитектура проекта.

### `async` / `await` / `throws` / `try`
```swift
let tasks = try await repository.fetchTasks()
```
- `await` — «здесь можно подождать». Пока ждём, интерфейс не замирает.
- `try` — «здесь может быть ошибка». Её либо обрабатывают через `do { } catch { }`, либо передают выше (`throws`).

Mock мог бы отвечать мгновенно и без ошибок, но сигнатуры уже `async throws`: когда придёт настоящая сеть,
ни один вызывающий код не придётся менять.

### `actor` — защита от гонок данных
Два экрана одновременно делают `tasks.append(...)`, и массив может испортиться. `actor` пускает к своим
данным строго по одному, поэтому снаружи каждый вызов идёт через `await`, даже если внутри нет никакого ожидания:
```swift
await repository.simulateFailure(.network)
```
`MockProjectRepository` — обычный `struct`: в нём ничего не меняется, значит, гонок быть не может и `actor` не нужен.

### `nonisolated`, `Sendable` и главный поток
В проекте по умолчанию **весь код привязан к главному потоку** (`MainActor`, см. модуль 0).
Для UI это удобно, но `actor` работает *не* на главном потоке. Если бы `TaskItem` был привязан
к главному потоку, `MockTaskRepository` не смог бы с ним работать.

Поэтому модели и протоколы помечены `nonisolated`, то есть «не привязан ни к какому потоку».
`Sendable` — «безопасно передавать между потоками». У `struct` из простых полей это получается
автоматически, а компилятор Swift 6 проверяет это за нас.

Правило для проекта: **модели и протоколы данных — `nonisolated`, ViewModel'и и View — на главном потоке.**

### `Identifiable` и `Hashable`
- `Identifiable` (есть `id`) нужен `List`/`ForEach`, чтобы отличать строки друг от друга.
- `Hashable` позволяет класть значение в `Set` и использовать как маршрут навигации (модуль 3).

### Тестируемость: зависимости передаются снаружи
```swift
func isOverdue(now: Date = .now) -> Bool        // а не Date() внутри
MockTaskRepository(latency: .zero)              // в тестах без задержки
MockData.tasks(now: fixedDate)                  // даты относительно переданного «сейчас»
```
Если функция сама берёт `Date()`, тест «просрочено ли» сегодня пройдёт, а завтра упадёт.
Когда всё, что меняется (время, задержка, ошибки), передаётся параметром, тест всегда даёт одинаковый результат.
Это та же идея, что и протоколы, только в малом масштабе.

### `enum` без `case` — пространство имён
`MockData` — `enum` без случаев. Создать `MockData()` нельзя, можно только `MockData.users`.
Так группируют константы и статические функции.

### Swift Testing: async и ошибки
```swift
@Test func fetch() async throws {                 // тест может быть async и throws
    let task = try #require(tasks.first)          // nil → тест останавливается
    await #expect(throws: RepositoryError.notFound) {
        try await repository.update(missing)       // ждём именно эту ошибку
    }
}
@Test(arguments: Role.allCases)                   // один тест на каждую роль
func rolePermissions(role: Role) { … }
```
В Swift Testing тестовый тип — `struct`, и для **каждого** теста создаётся новый экземпляр.
Поэтому `let repository = MockTaskRepository(...)` свежий в каждом тесте, и тесты не влияют друг на друга.

---

## Что пошло не так (и чему это учит)
1. **Снова `missing import of defining module 'Foundation'`** — для `.now` в тестах.
   Правило из модуля 0 работает: добавил `import Foundation`.
2. **SwiftFormat сам переносит длинные строки** (`--maxwidth 120`). Комментарий
   `swiftlint:disable line_length` после этого стал лишним, и SwiftLint предупредил:
   `superfluous_disable_command`. Убрал его. Вывод: не отключай правила «на всякий случай».

## Проверка (2026-11-05)
| Что | Результат |
|-----|-----------|
| Сборка, iPhone 17 Simulator | ✅ без предупреждений |
| Unit-тесты | ✅ 19/19 |
| UI-тест | ✅ 1/1 |
| SwiftLint `--strict`, SwiftFormat `--lint` | ✅ |

---

## Упражнения
1. Добавь в `Priority` случай `case critical`. Собери (⌘B) и посмотри, сколько ошибок покажет компилятор
   и где. Исправь их (вес `4`, название «Критический») или удали случай. Тест `rawValuesMatchBackend` тоже упадёт — почему?
2. Добавь в `TaskItem` вычисляемое свойство `var isAssigned: Bool` (есть ли `assignee`) и тест на него.
3. В `MockTaskRepository` убери слово `actor` и напиши `final class`. Прочитай, что скажет компилятор
   Swift 6 о `Sendable`. Верни `actor`.
4. Попробуй в тесте вызвать `repository.simulateFailure(.network)` без `await`. Что за ошибка и почему?
