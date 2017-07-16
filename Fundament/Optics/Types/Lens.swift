import Foundation

public typealias LensType = TraversalType & GetterType & SetterType

extension SetterType where Self: LensType {
    public func map(from source: Source, over transform: (Aspect) -> Detail) -> Target {
        return set(from: source, to: transform(get(from: source)))
    }
}

// MARK: - AnyLens

public class AnyLens<S, T, A, B>: LensType {
    public typealias Source = S
    public typealias Target = T
    public typealias Aspect = A
    public typealias Detail = B

    private let _get: (Source) -> Aspect
    private let _set: (Source, Detail) -> Target

    public init(get: @escaping (Source) -> Aspect, set: @escaping (Source, Detail) -> Target) {
        _get = get
        _set = set
    }

    public convenience init<L: LensType>(_ lens: L)
        where Source == L.Source, Target == L.Target, Aspect == L.Aspect, Detail == L.Detail {
            self.init(get: lens.get(from:), set: lens.set(from:to:))
    }

    public func get(from source: Source) -> Aspect {
        return _get(source)
    }

    public func set(from source: Source, to detail: Detail) -> Target {
        return _set(source, detail)
    }
}

public class Lens<Whole, Part>: AnyLens<Whole, Whole, Part, Part> {}
