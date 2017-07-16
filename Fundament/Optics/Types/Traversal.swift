import Foundation

public typealias TraversalType = ReducerType & MapperType

// MARK: - AnyTraversal

public class AnyTraversal<S, T, A, B>: TraversalType {
    public typealias Source = S
    public typealias Target = T
    public typealias Aspect = A
    public typealias Detail = B

    private let _map: (Source, (Aspect) -> Detail) -> Target
    private let _reduce: (Source, Any, (Any, Aspect) -> Any) -> Any

    public init(map: @escaping (Source, (Aspect) -> Detail) -> Target,
                reduce: @escaping (Source, Any, (Any, Aspect) -> Any) -> Any) {
        _map = map
        _reduce = reduce
    }

    public convenience init<T: TraversalType>(_ traversal: T)
        where Source == T.Source, Target == T.Target, Aspect == T.Aspect, Detail == T.Detail {
            self.init(map: traversal.map(from:over:), reduce: { whole, initial, combine in
                traversal.reduce(from: whole, to: initial, combine: combine)
            })
    }

    public func reduce<T>(from source: Source, to initialValue: T, combine: (T, Aspect) -> T) -> T {
        return _reduce(source, initialValue) { combine($0 as! T, $1) } as! T
    }

    public func map(from source: Source, over transform: (Aspect) -> Detail) -> Target {
        return _map(source, transform)
    }
}

public class Traversal<Whole, Part>: AnyTraversal<Whole, Whole, Part, Part> {}
