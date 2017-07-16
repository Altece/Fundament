import Foundation

public protocol ReducerType {
    associatedtype Source
    associatedtype SourceValue

    func reduce<T>(from source: Source, to initialValue: T, combine: (T, SourceValue) -> T) -> T

    func tryGet(from source: Source) -> SourceValue?
    func survey(from source: Source) -> Either<Source, SourceValue>
}

extension ReducerType {
    public func tryGet(from source: Source) -> SourceValue? {
        return self.reduce(from: source, to: nil as SourceValue?) { $0.map { $0 } ?? $1 }
    }

    public func survey(from source: Source) -> Either<Source, SourceValue> {
        return tryGet(from: source).map(Either.right) ?? .left(source)
    }
}

// MARK: - AnyReducer

public class AnyReducer<S, A>: ReducerType {
    public typealias Source = S
    public typealias SourceValue = A

    private let _reduce: (Source, Any, (Any, SourceValue) -> Any) -> Any

    public init(_ reduce: @escaping (Source, Any, (Any, SourceValue) -> Any) -> Any) {
        _reduce = reduce
    }

    public convenience init<R: ReducerType>(_ reducer: R)
        where Source == R.Source, SourceValue == R.SourceValue {
            self.init() { whole, initial, combine in
                reducer.reduce(from: whole, to: initial, combine: combine)
            }
    }

    public func reduce<T>(from source: Source,
                          to initialValue: T,
                          combine: (T, SourceValue) -> T) -> T {
        return _reduce(source, initialValue) { combine($0 as! T, $1) } as! T
    }
}

public typealias Reducer<Whole, Part> = AnyReducer<Whole, Part>
