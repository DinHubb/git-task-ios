import Foundation

/// Состояние загрузки данных для экрана.
///
/// Вместо трёх отдельных переменных (`isLoading`, `error`, `items`), которые могут прийти
/// в бессмысленную комбинацию («загружается И ошибка И данные»), — один `enum`:
/// экран всегда ровно в одном состоянии. Это называют «make impossible states impossible».
///
/// `<Value>` — *дженерик*: один тип для любых данных. `LoadState<[TaskItem]>`, `LoadState<User>`…
nonisolated enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(message: String)

    /// Загруженные данные или `nil`, если их ещё нет.
    var value: Value? {
        if case let .loaded(value) = self {
            value
        } else {
            nil
        }
    }
}

/// `Equatable` только когда сами данные `Equatable` — так тесты могут сравнивать состояния через `==`.
nonisolated extension LoadState: Equatable where Value: Equatable {}

nonisolated extension LoadState: Sendable where Value: Sendable {}
