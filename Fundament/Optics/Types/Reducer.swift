import Foundation

public protocol ReducerType {
    associatedtype Source
    associatedtype Aspect

    func reduce<T>(from source: Source, to initialValue: T, combine: (T, Aspect) -> T) -> T

    func tryGet(from source: Source) -> Aspect?
    func survey(from source: Source) -> Either<Source, Aspect>
}

extension ReducerType {
    public func tryGet(from source: Source) -> Aspect? {
        return self.reduce(from: source, to: nil as Aspect?) { $0.map { $0 } ?? $1 }
    }

    public func survey(from source: Source) -> Either<Source, Aspect> {
        return tryGet(from: source).map(Either.right) ?? .left(source)
    }
}

// MARK: - AnyReducer

public class AnyReducer<S, A>: ReducerType {
    public typealias Source = S
    public typealias Aspect = A

    private let _reduce: (Source, Any, (Any, Aspect) -> Any) -> Any

    public init(_ reduce: @escaping (Source, Any, (Any, Aspect) -> Any) -> Any) {
        _reduce = reduce
    }

    public convenience init<R: ReducerType>(_ reducer: R)
        where Source == R.Source, Aspect == R.Aspect {
            self.init() { whole, initial, combine in
                reducer.reduce(from: whole, to: initial, combine: combine)
            }
    }

    public func reduce<T>(from source: Source, to initialValue: T, combine: (T, Aspect) -> T) -> T {
        return _reduce(source, initialValue) { combine($0 as! T, $1) } as! T
    }
}

public typealias Reducer<Whole, Part> = AnyReducer<Whole, Part>
