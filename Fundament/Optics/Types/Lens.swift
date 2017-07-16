import Foundation

public typealias LensType = TraversalType & GetterType & SetterType

extension SetterType where Self: LensType {
    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return set(from: source, to: transform(get(from: source)))
    }
}

// MARK: - AnyLens

public class AnyLens<S, T, A, B>: LensType {
    public typealias Source = S
    public typealias Target = T
    public typealias SourceValue = A
    public typealias TargetValue = B

    private let _get: (Source) -> SourceValue
    private let _set: (Source, TargetValue) -> Target

    public init(get: @escaping (Source) -> SourceValue, set: @escaping (Source, TargetValue) -> Target) {
        _get = get
        _set = set
    }

    public convenience init<L: LensType>(_ lens: L)
        where Source == L.Source, Target == L.Target, SourceValue == L.SourceValue, TargetValue == L.TargetValue {
            self.init(get: lens.get(from:), set: lens.set(from:to:))
    }

    public func get(from source: Source) -> SourceValue {
        return _get(source)
    }

    public func set(from source: Source, to targetValue: TargetValue) -> Target {
        return _set(source, targetValue)
    }
}

public class Lens<Whole, Part>: AnyLens<Whole, Whole, Part, Part> {}
