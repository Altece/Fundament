import Foundation

public typealias TraversalType = ReducerType & MapperType

// MARK: - AnyTraversal

public class AnyTraversal<S, T, A, B>: TraversalType {
    public typealias Source = S
    public typealias Target = T
    public typealias SourceValue = A
    public typealias TargetValue = B

    fileprivate let _map: (Source, (SourceValue) -> TargetValue) -> Target
    fileprivate let _reduce: (Source, Any, (Any, SourceValue) -> Any) -> Any

    public init(map: @escaping (Source, (SourceValue) -> TargetValue) -> Target,
                reduce: @escaping (Source, Any, (Any, SourceValue) -> Any) -> Any) {
        _map = map
        _reduce = reduce
    }

    public convenience init<T: TraversalType>(_ traversal: T) where
        Source == T.Source,
        Target == T.Target,
        SourceValue == T.SourceValue,
        TargetValue == T.TargetValue {
            self.init(map: traversal.map(from:over:), reduce: { whole, initial, combine in
                traversal.reduce(from: whole, to: initial, combine: combine)
            })
    }

    public func reduce<T>(from source: Source,
                          to initialValue: T,
                          combine: (T, SourceValue) -> T) -> T {
        return _reduce(source, initialValue) { combine($0 as! T, $1) } as! T
    }

    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return _map(source, transform)
    }
}

public class Traversal<Whole, Part>: AnyTraversal<Whole, Whole, Part, Part> {}

// MARK: - Composition

public func compose<PT: TraversalType, CT: TraversalType>(traversal parent: PT, with child: CT)
    -> AnyTraversal<PT.Source, PT.Target, CT.SourceValue, CT.TargetValue> where
    PT.SourceValue == CT.Source,
    PT.TargetValue == CT.Target {
        return AnyTraversal<PT.Source, PT.Target, CT.SourceValue, CT.TargetValue>(
            map: { source, transform in
                parent.map(from: source) { value in
                    child.map(from: value, over: transform)
                }
        }, reduce: { source, initial, combine in
            parent.reduce(from: source, to: initial) { combined, value in
                child.reduce(from: value, to: combined, combine: combine)
            }
        })
}

public func compose<PT: TraversalType, CT: TraversalType>(traversal parent: PT, with child: CT)
    -> Traversal<PT.Source, CT.SourceValue> where
    PT.SourceValue == CT.Source,
    PT.TargetValue == CT.Target,
    PT.Source == PT.Target,
    CT.SourceValue == CT.TargetValue {
        let composed: AnyTraversal = compose(traversal: parent, with: child)
        return Traversal<PT.Source, CT.SourceValue>(map: composed._map, reduce: composed._reduce)
}
