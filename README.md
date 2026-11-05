# GitTask iOS

iOS-клиент для [GitTaskBot](https://github.com/Hadamot/GitTaskBot) — управление задачами GitHub Issues.
Учебный проект: SwiftUI + MVVM + Repository. Сейчас работает на тестовых данных.

## Быстрый старт
```bash
sudo xcode-select -s /Applications/Xcode.app   # один раз: использовать полный Xcode
make bootstrap                                  # SwiftLint + SwiftFormat
open gitTask.xcodeproj                          # ⌘R — запуск
```

## Требования
- Xcode 26+, iOS Simulator 26+
- Homebrew

## Документация
- [Архитектура и дорожная карта](docs/ARCHITECTURE.md)
- [Модули](docs/modules/) — что сделано на каждом шаге и почему

## Коммиты
Формат: `type: описание на русском`. Типы: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`.
