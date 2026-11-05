# Модуль 0 — Окружение и каркас проекта

**Итог:** проект собирается под iPhone на Swift 6, код проверяется SwiftLint при каждой сборке,
форматируется SwiftFormat, тесты на Swift Testing, репозиторий подключён к GitHub.

---

## Что сделано

### 1. Инструменты
| Инструмент | Зачем | Как поставлен |
|------------|-------|---------------|
| Xcode 26.4.1 | IDE, компилятор, симуляторы | App Store |
| iOS Simulator 26.4 | запуск приложения без телефона | `xcodebuild -downloadPlatform iOS` |
| SwiftLint | ловит ошибки стиля и опасные конструкции | `brew install swiftlint` |
| SwiftFormat | автоматически расставляет отступы, переносы, порядок импортов | `brew install swiftformat` |

### 2. Настройки проекта (`project.pbxproj`)
| Настройка | Было | Стало | Почему |
|-----------|------|-------|--------|
| `TARGETED_DEVICE_FAMILY` | `1,2,7` (iPhone, iPad, Vision) | `1` (iPhone) | одна раскладка — меньше вёрстки |
| `SUPPORTED_PLATFORMS` | + macOS, visionOS | только iOS | не собираем то, что не используем |
| `IPHONEOS_DEPLOYMENT_TARGET` | 26.4 | 26.0 | шире охват устройств, API те же |
| `SWIFT_VERSION` | 5.0 | 6.0 | строгая проверка многопоточности |
| Ориентация | портрет + ландшафт | только портрет | проще вёрстка на старте |
| `ENABLE_USER_SCRIPT_SANDBOXING` (app) | YES | NO | скрипту SwiftLint нужно читать исходники |
| Build Phase «SwiftLint» | — | добавлена | предупреждения видны прямо в Xcode |

Уже были включены (дефолт Xcode 26) и важны для нас:
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — весь код по умолчанию выполняется на **главном потоке**.
  UI в iOS можно трогать только с главного потока, так что это безопасный дефолт.
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` — набор «облегчённых» правил concurrency для новичков.
- `PBXFileSystemSynchronizedRootGroup` — Xcode **сам** видит файлы в папках. Создал файл в Finder
  или терминале — он уже в проекте. Раньше каждый файл нужно было добавлять вручную.

### 3. Структура
```
gitTask/
├── .swiftlint.yml        # правила линтера
├── .swiftformat          # правила форматирования
├── .gitignore
├── Makefile              # make lint / format / build / test
├── docs/
│   ├── ARCHITECTURE.md   # общая архитектура и дорожная карта
│   └── modules/          # этот файл и следующие
├── gitTask/
│   ├── App/
│   │   ├── GitTaskApp.swift   # точка входа (@main)
│   │   └── RootView.swift     # корневой экран (пока заглушка)
│   └── Resources/
│       └── Assets.xcassets
├── gitTaskTests/ExampleTests.swift        # пример Swift Testing
└── gitTaskUITests/AppLaunchUITests.swift  # smoke UI-тест
```

### 4. Git
- `origin` → `https://github.com/DinHubb/git-task-ios.git`
- `xcuserdata/` убран из git: это личные настройки Xcode (открытые вкладки, схемы), у каждого свои.

---

## Концепции, которые стоит понять

### Как запускается SwiftUI-приложение
```swift
@main                        // 1. «Программа начинается здесь»
struct GitTaskApp: App {     // 2. App — описание приложения
    var body: some Scene {   // 3. Сцена — окно
        WindowGroup {
            RootView()       // 4. Первый экран
        }
    }
}
```
**`some Scene` / `some View`** — «непрозрачный тип»: «я верну *какой-то конкретный* тип View,
компилятор знает какой, а тебе знать не обязательно». Это нужно, потому что реальный тип
вёрстки выглядит как `VStack<TupleView<(Text, Image)>>` — писать такое руками невозможно.

### View — это `struct`, а не объект на экране
`RootView` — это **описание** того, что должно быть на экране. SwiftUI сам создаёт и обновляет
настоящие элементы. Поэтому View дешёвые: их можно пересоздавать сотни раз в секунду.

### Модификаторы
```swift
ContentUnavailableView(...)
    .navigationTitle("GitTask")
```
Каждый `.modifier()` возвращает **новую** View, обёрнутую вокруг старой. Порядок важен:
`.padding().background(.red)` и `.background(.red).padding()` выглядят по-разному — попробуй в Preview.

### `#Preview`
Макрос, который показывает экран в Canvas справа от кода (⌥⌘↩ — показать/скрыть Canvas).
Приложение запускать не нужно.

### Swift Testing vs XCTest
```swift
// XCTest (старый)                    // Swift Testing (новый)
class MyTests: XCTestCase {           struct MyTests {
  func testSum() {                      @Test func sum() {
    XCTAssertEqual(2 + 2, 4)              #expect(2 + 2 == 4)
  }                                     }
}                                     }
```
`#expect` при провале показывает значения обеих сторон. `arguments:` запускает один тест на наборе данных.

### SwiftLint vs SwiftFormat
- **SwiftFormat** — *исправляет* внешний вид кода (пробелы, переносы). Запускаешь — код меняется.
- **SwiftLint** — *находит* проблемы и пишет предупреждения (например, `force_unwrapping`: `value!`
  крашнет приложение, если там `nil`). Код не меняет — исправляешь ты.

Два правила SwiftLint (`trailing_comma`, `opening_brace`) выключены, потому что спорят со SwiftFormat.

### Импорты: каждый файл импортирует то, что использует
В проекте включено `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY` (будет стандартом в Swift 7).
Без него методы `Foundation` «протекали» в файл, даже если ты его не импортировал.
Теперь — нет. Первая сборка упала именно на этом:
```
error: instance method 'trimmingCharacters(in:)' is not available
       due to missing import of defining module 'Foundation'
```
Исправление — `import Foundation` в `ExampleTests.swift`. Правило: **видишь такую ошибку —
добавь импорт модуля, который назван в сообщении.**

---

## Проверка (2026-11-05)
| Что | Результат |
|-----|-----------|
| Сборка, iPhone 17 Simulator (iOS 26.4) | ✅ |
| Unit-тесты (Swift Testing) | ✅ 4/4 (параметризованный тест прогнан на 3 входах) |
| UI-тест запуска | ✅ 1/1 |
| SwiftLint `--strict` (в т.ч. build phase) | ✅ 0 нарушений |
| SwiftFormat `--lint` | ✅ |

---

## Команды
```bash
make help      # список команд
make format    # отформатировать код
make lint      # проверить стиль
make build     # собрать
make test      # тесты
```
В Xcode: **⌘B** — собрать, **⌘R** — запустить, **⌘U** — тесты.

---

## Упражнения
1. Открой `RootView.swift`, включи Canvas (⌥⌘↩). Поменяй `systemImage: "checklist"` на `"star.fill"`.
   Все иконки — в приложении **SF Symbols** (скачать с developer.apple.com/sf-symbols).
2. Добавь к `ContentUnavailableView` модификатор `.foregroundStyle(.orange)` и посмотри, что поменялось.
3. Напиши в `RootView` строку `let x: String? = nil; let y = x!` и собери (⌘B). Найди предупреждение
   SwiftLint в Issue Navigator (⌘5). Удали строку.
4. Добавь в `ExampleTests` свой `@Test`, который проверяет `"abc".count == 3`, и запусти ромбиком слева от теста.
