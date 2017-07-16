import Foundation

public typealias IsomorphType = LensType & PrismType

extension ResetType where Self: IsomorphType, Self.Source == Self.Target {
    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return set(from: source, to: transform(get(from: source)))
    }
}

extension SetterType where Self: IsomorphType {
    public func set(from source: Source, to targetValue: TargetValue) -> Target {
        return reset(to: targetValue)
    }
}

// MARK: - AnyIsomorph

public class AnyIsomorph<S, T, A, B>: IsomorphType {
    public typealias Source = S
    public typealias Target = T
    public typealias SourceValue = A
    public typealias TargetValue = B

    private let _get: (Source) -> SourceValue
    private let _make: (TargetValue) -> Target

    public init(get: @escaping (Source) -> SourceValue, make: @escaping (TargetValue) -> Target) {
        _get = get
        _make = make
    }

    public convenience init<I: IsomorphType>(_ isomorph: I)
        where Source == I.Source, Target == I.Target, SourceValue == I.SourceValue, TargetValue == I.TargetValue {
            self.init(get: isomorph.get(from:), make: isomorph.reset(to:))
    }

    public func get(from source: Source) -> SourceValue {
        return _get(source)
    }

    public func reset(to targetValue: TargetValue) -> Target {
        return _make(targetValue)
    }
}

public class Isomorph<Whole, Part>: AnyIsomorph<Whole, Whole, Part, Part> {}
