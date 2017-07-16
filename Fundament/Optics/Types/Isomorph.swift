import Foundation

public typealias IsomorphType = LensType & PrismType

extension ResetterType where Self: IsomorphType, Self.Source == Self.Target {
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

    fileprivate let _get: (Source) -> SourceValue
    fileprivate let _reset: (TargetValue) -> Target

    public init(get: @escaping (Source) -> SourceValue, reset: @escaping (TargetValue) -> Target) {
        _get = get
        _reset = reset
    }

    public convenience init<I: IsomorphType>(_ isomorph: I)
        where Source == I.Source, Target == I.Target, SourceValue == I.SourceValue, TargetValue == I.TargetValue {
            self.init(get: isomorph.get(from:), reset: isomorph.reset(to:))
    }

    public func get(from source: Source) -> SourceValue {
        return _get(source)
    }

    public func reset(to targetValue: TargetValue) -> Target {
        return _reset(targetValue)
    }
}

public class Isomorph<Whole, Part>: AnyIsomorph<Whole, Whole, Part, Part> {}

// MARK: - Composition

public func compose<PI: IsomorphType, CI: IsomorphType>(isomorph parent: PI, with child: CI)
    -> AnyIsomorph<PI.Source, PI.Target, CI.SourceValue, CI.TargetValue>
    where PI.SourceValue == CI.Source, PI.TargetValue == CI.Target {
        return AnyIsomorph<PI.Source, PI.Target, CI.SourceValue, CI.TargetValue>(
            get: { source in child.get(from: parent.get(from: source)) },
            reset: { value in parent.reset(to: child.reset(to: value)) })
}

public func compose<PI: IsomorphType, CI: IsomorphType>(isomorph parent: PI, with child: CI)
    -> Isomorph<PI.Source, CI.SourceValue>
    where PI.SourceValue == CI.Source, PI.TargetValue == CI.Target, PI.Source == PI.Target, CI.SourceValue == CI.TargetValue {
        let composed: AnyIsomorph = compose(isomorph: parent, with: child)
        return Isomorph<PI.Source, CI.SourceValue>(get: composed._get, reset: composed._reset)
}
