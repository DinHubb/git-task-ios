# Короткие команды для терминала. Запуск: make <команда>
# Xcode делает то же самое кнопками, но в CI и терминале удобнее так.

PROJECT     = gitTask.xcodeproj
SCHEME      = gitTask
SIMULATOR  ?= iPhone 17
DESTINATION = platform=iOS Simulator,name=$(SIMULATOR)
export DEVELOPER_DIR ?= /Applications/Xcode.app/Contents/Developer

.PHONY: help bootstrap format lint build test

help:          ## Показать список команд
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'

bootstrap:     ## Установить инструменты (SwiftLint, SwiftFormat)
	brew install swiftlint swiftformat

format:        ## Отформатировать весь код
	swiftformat .

lint:          ## Проверить стиль (SwiftFormat + SwiftLint)
	swiftformat --lint .
	swiftlint --strict

build:         ## Собрать приложение для симулятора
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -quiet build

test:          ## Запустить unit- и UI-тесты
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -quiet test
