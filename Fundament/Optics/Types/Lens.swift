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

    fileprivate let _get: (Source) -> SourceValue
    fileprivate let _set: (Source, TargetValue) -> Target

    public init(get: @escaping (Source) -> SourceValue,
                set: @escaping (Source, TargetValue) -> Target) {
        _get = get
        _set = set
    }

    public convenience init<L: LensType>(_ lens: L) where
        Source == L.Source,
        Target == L.Target,
        SourceValue == L.SourceValue,
        TargetValue == L.TargetValue {
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

// MARK: - Composition

public func compose<PL: LensType, CL: LensType>(lens parent: PL, with child: CL)
    -> AnyLens<PL.Source, PL.Target, CL.SourceValue, CL.TargetValue> where
    PL.SourceValue == CL.Source,
    PL.TargetValue == CL.Target {
        return AnyLens<PL.Source, PL.Target, CL.SourceValue, CL.TargetValue>(
            get: { source in child.get(from: parent.get(from: source)) },
            set: { source, value in
                parent.set(from: source,
                           to: child.set(from: parent.get(from: source),
                                         to: value))
        })
}

public func compose<PL: LensType, CL: LensType>(lens parent: PL, with child: CL)
    -> Lens<PL.Source, CL.SourceValue> where
    PL.SourceValue == CL.Source,
    PL.TargetValue == CL.Target,
    PL.Source == PL.Target,
    CL.SourceValue == CL.TargetValue {
        let composed: AnyLens = compose(lens: parent, with: child)
        return Lens<PL.Source, CL.SourceValue>(get: composed._get, set: composed._set)
}
