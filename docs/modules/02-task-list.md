# Модуль 2 — Список задач (первый экран, MVVM)

**Итог:** при запуске видно вкладки внизу и список из 18 тестовых задач с бейджами приоритета и колонки,
ответственным и дедлайном («послезавтра», «вчера»; просроченные — красным).
Есть состояния загрузки, ошибки с «Повторить» и пустого списка, pull-to-refresh.

---

## Что сделано

```
gitTask/
├── App/
│   ├── GitTaskApp.swift        # создаёт AppContainer.mock()
│   ├── AppContainer.swift      # DI: какие репозитории использует приложение
│   └── RootView.swift          # TabView: Задачи / Статистика (заглушка) / Профиль (заглушка)
├── Core/
│   ├── Common/LoadState.swift  # idle / loading / loaded / failed — для любого экрана
│   └── DesignSystem/
│       ├── ModelStyles.swift   # цвета и иконки для Priority, BoardColumn
│       ├── Badge.swift         # «таблетка» с иконкой и текстом
│       └── ErrorStateView.swift# экран ошибки с «Повторить»
└── Features/TaskList/
    ├── TaskListViewModel.swift # состояние и логика экрана
    ├── TaskListView.swift      # вёрстка экрана + 4 Preview
    └── TaskRow.swift           # одна строка списка

gitTaskTests/
├── Support/StubTaskRepository.swift     # тестовый двойник с счётчиком вызовов
└── Features/TaskListViewModelTests.swift# 8 тестов ViewModel
gitTaskUITests/AppLaunchUITests.swift    # список задач и вкладки видны
```

Также язык разработки проекта сменён с `en` на `ru` — см. «Что пошло не так».

---

## Как это работает вместе

```
GitTaskApp
  └─ AppContainer.mock()                 ← выбрали mock-данные (одна строка)
       └─ RootView(container:)
            └─ @State taskListViewModel  ← создан один раз, живёт всё время
                 └─ TaskListView(viewModel:)
                      .task { await viewModel.loadIfNeeded() }
                                 │
       TaskListViewModel.load() ─┘
         state = .loading          → View показывает ProgressView
         try await repository.fetchTasks()   (0,5 с «сети»)
         state = .loaded(tasks)    → View показывает List
         или .failed(message)      → View показывает ErrorStateView
```

**Однонаправленный поток:** View → вызывает метод ViewModel → ViewModel меняет `state` →
SwiftUI сам перерисовывает View. View никогда не меняет `state` напрямую (`private(set)`).

---

## Концепции

### MVVM на практике
| | View (`TaskListView`) | ViewModel (`TaskListViewModel`) |
|-|------|-----------|
| Тип | `struct` — пересоздаётся постоянно | `final class` — один объект на всё время жизни |
| Знает | как показать `state` | откуда взять данные, как обработать ошибку |
| Не знает | откуда данные | про `List`, цвета, шрифты |
| Тестируем | Preview, UI-тесты | unit-тесты (быстрые, без симулятора UI) |

Почему это важно: 8 тестов ViewModel проверяют *всю* логику экрана за доли секунды, не запуская интерфейс.

### `@Observable`
```swift
@Observable final class TaskListViewModel {
    private(set) var state: LoadState<[TaskItem]> = .idle
}
```
SwiftUI запоминает, какие свойства View прочитала в `body`. Изменилось `state` — перерисуется
только та View, что его читала. Никаких `@Published`, `objectWillChange` (это старый способ, `ObservableObject`).

### Кто *владеет* ViewModel: `@State` vs `let`
```swift
// RootView — ВЛАДЕЛЕЦ: создаёт и хранит
@State private var taskListViewModel: TaskListViewModel

// TaskListView — ПОЛЬЗОВАТЕЛЬ: просто получает ссылку
let viewModel: TaskListViewModel
```
View — `struct`, SwiftUI пересоздаёт её при каждой перерисовке родителя. Если бы `RootView` писал
`TaskListView(viewModel: TaskListViewModel(...))` прямо в `body`, ViewModel создавался бы заново
и терял загруженные задачи. `@State` говорит SwiftUI: «сохрани это значение между перерисовками».
**Правило:** `@State` — у того, кто создаёт объект; остальные получают его через `let`.

### `LoadState` — «невозможные состояния невозможны»
Три переменные `isLoading`, `error`, `tasks` дают 8 комбинаций, половина бессмысленна
(«грузится и ошибка одновременно»). Один `enum` — ровно одно состояние в каждый момент,
а `switch` в View обязан обработать каждое — компилятор не даст забыть экран ошибки.

`LoadState<Value>` — **дженерик**: один тип для любых данных (`LoadState<[TaskItem]>`, позже `LoadState<User>`).
`extension LoadState: Equatable where Value: Equatable` — *условное соответствие*:
сравнивать через `==` можно, только если сами данные сравниваемые.

### `.task` и отмена
```swift
.task { await viewModel.loadIfNeeded() }
```
Запускает async-работу при появлении экрана и **отменяет** её при исчезновении. Отменённый
`Task.sleep` бросает `CancellationError` — это не ошибка, поэтому ViewModel ловит её отдельно
(`catch is CancellationError`) и не показывает «Не удалось загрузить». `loadIfNeeded()` не перезагружает
данные при каждом возврате на вкладку.

### `@ViewBuilder` и `switch` в View
```swift
@ViewBuilder private var content: some View {
    switch viewModel.state {
    case .idle, .loading: ProgressView()
    case let .loaded(tasks) where tasks.isEmpty: ContentUnavailableView(...)
    case let .loaded(tasks): List(tasks) { TaskRow(task: $0) }
    ...
```
`some View` должен быть *одним* типом, а ветки возвращают разные. `@ViewBuilder` склеивает их в один.
`case let .loaded(tasks) where ...` — сопоставление с образцом с условием; порядок `case` важен.

### Расширения (`extension`) для разделения слоёв
`Priority` живёт в `Core/Models` без SwiftUI. Цвет и иконку дописывает `extension Priority` в
`DesignSystem/ModelStyles.swift`. Модель чистая, а внешний вид — рядом с остальным дизайном.

### Переиспользуемые компоненты и замыкания
`Badge`, `ErrorStateView` ничего не знают про задачи. `ErrorStateView` получает `retry: () async -> Void` —
*замыкание*, «что сделать при нажатии». Решает тот, кто показывает экран.

### DI-контейнер
`AppContainer` — единственное место, где написано `MockTaskRepository()`. Когда появится бэкенд:
`AppContainer.live()` с `APITaskRepository` и одна строка в `GitTaskApp`. Ни один экран не изменится.

### Тестовые двойники: mock vs stub
- **`MockTaskRepository`** (в приложении) — правдоподобный «сервер» для запуска и Preview.
- **`StubTaskRepository`** (в тестах) — отдаёт ровно то, что задал тест, и считает вызовы.
  Так проверяем, например, что `loadIfNeeded()` дважды подряд ходит в репозиторий **один** раз.

### Preview для каждого состояния
В `TaskListView.swift` четыре `#Preview`: «Данные», «Пусто», «Ошибка», «Долгая загрузка».
Переключаются вверху Canvas. Mock-репозиторий с параметрами (`tasks: []`, `failure: .network`,
`latency: .seconds(3600)`) — вот где окупилась его настраиваемость из модуля 1.

---

## Что пошло не так (и чему это учит)

### 1. Странная ошибка компилятора про `nonisolated` в тестовом stub'е
```
StubTaskRepository.swift:9:7: error: 'nonisolated' modifier cannot be applied to this declaration
actor StubTaskRepository: TaskRepository {
```
Слова `nonisolated` в файле нет. Причина: протокол `TaskRepository` помечен `nonisolated` (модуль 1),
а Swift **переносит изоляцию протокола на тип**, если соответствие объявлено прямо в объявлении типа
(`actor X: Protocol`). `nonisolated actor` не бывает — отсюда ошибка. В основном таргете этого не
видно, там действует изоляция по умолчанию `MainActor`, а в тестовом таргете — нет.

Решение — объявить соответствие **в расширении**: из расширений изоляция не выводится.
```swift
actor StubTaskRepository { ... }                 // данные
extension StubTaskRepository: TaskRepository { } // методы протокола
```
Сначала я попробовал `@MainActor final class` — получил другую ошибку того же происхождения
(методы протокола стали `nonisolated` и не могли трогать свойства класса). Вывод: если ошибка
упоминает то, чего нет в коде, — ищи, *откуда компилятор это вывел*.

### 2. Даты по-английски: «in 2 days», «yesterday»
Тесты этого поймать не могли — нашлось на скриншоте. Форматтер дат выбирает язык из тех, что
*поддерживает приложение*. Проект создан с `developmentRegion = en`, поэтому даже русский текст
интерфейса соседствовал с английскими датами. Сменил на `ru` → «послезавтра», «вчера».
**Вывод:** всегда смотри на экран глазами, тесты проверяют логику, а не вид.

### 3. Сознательное упрощение
Если *обновление* (pull-to-refresh) падает с ошибкой, уже показанные задачи заменяются экраном ошибки
(тест `refreshFailureShowsError` это фиксирует). Лучше было бы оставить список и показать `alert` —
сделаем в модуле 3, когда появятся алерты для действий над задачей.

---

## Проверка (2026-11-05)
| Что | Результат |
|-----|-----------|
| Сборка, iPhone 17 Simulator | ✅ без предупреждений |
| Unit-тесты | ✅ 27/27 (19 из модуля 1 + 8 ViewModel) |
| UI-тесты | ✅ 2/2 (список задач, вкладки) |
| SwiftLint `--strict`, SwiftFormat `--lint` | ✅ |
| Скриншот: список, бейджи, русские даты, вкладки | ✅ |

---

## Упражнения
1. Открой `TaskListView.swift`, Canvas (⌥⌘↩), переключай Preview «Данные / Пусто / Ошибка / Долгая загрузка».
2. В `MockTaskRepository` (модуль 1) поставь по умолчанию `failure: .network`, запусти (⌘R) — увидишь
   экран ошибки. Нажми «Повторить»: снова ошибка, ведь mock всегда падает. Верни как было.
3. В симуляторе потяни список вниз — сработает `.refreshable`. Сколько длится индикатор и почему?
4. Добавь в `TaskRow` строку с `task.description`, если оно не пустое
   (подсказка: `if !task.description.isEmpty { Text(...) .lineLimit(2) }`).
5. Убери `@State` у `taskListViewModel` в `RootView` (оставь `private var`). Что скажет компилятор?
   Подсказка: `init` меняет `_taskListViewModel` — что такое подчёркивание?
