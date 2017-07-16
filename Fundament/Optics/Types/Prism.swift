import Foundation

public typealias PrismType = TraversalType & SetterType & ResetterType

extension ResetterType where Self: PrismType, Self.Source == Self.Target {
    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return tryGet(from: source).map(transform).map(reset(to:)) ?? source
    }
}

extension ReducerType where Self: PrismType {
    public func reduce<T>(from source: Source,
                          to initialValue: T,
                          combine: (T, SourceValue) -> T) -> T {
        return tryGet(from: source).map { combine(initialValue, $0) } ?? initialValue
    }
}

// MARK: - AnyPrism

public class AnyPrism<S, T, A, B>: PrismType {
    public typealias Source = S
    public typealias Target = T
    public typealias SourceValue = A
    public typealias TargetValue = B

    fileprivate let _tryGet: (Source) -> SourceValue?
    fileprivate let _reset: (TargetValue) -> Target
    private let _map: (Source, (SourceValue) -> TargetValue) -> Target

    public init(tryGet: @escaping (Source) -> SourceValue?,
                reset: @escaping (TargetValue) -> Target,
                map: @escaping (Source, (SourceValue) -> TargetValue) -> Target) {
        _tryGet = tryGet
        _reset = reset
        _map = map
    }

    public convenience init<P: PrismType>(_ prism: P) where
        Source == P.Source,
        Target == P.Target,
        SourceValue == P.SourceValue,
        TargetValue == P.TargetValue {
            self.init(tryGet: prism.tryGet(from:),
                      reset: prism.reset(to:),
                      map: prism.map(from:over:))
    }

    public func tryGet(from source: Source) -> SourceValue? {
        return _tryGet(source)
    }

    public func reset(to targetValue: TargetValue) -> Target {
        return _reset(targetValue)
    }

    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return _map(source, transform)
    }
}

public class Prism<Whole, Part>: AnyPrism<Whole, Whole, Part, Part> {
    public init(tryGet: @escaping (Source) -> SourceValue?,
                reset: @escaping (TargetValue) -> Target) {
        super.init(tryGet: tryGet, reset: reset, map: { whole, transform in
            tryGet(whole).map(transform).map(reset) ?? whole
        })
    }

    public convenience init<P: PrismType>(_ prism: P)
        where Whole == P.Source, Whole == P.Target, Part == P.SourceValue, Part == P.TargetValue {
            self.init(tryGet: prism.tryGet(from:),
                      reset: prism.reset(to:))
    }
}

// MARK: - Composition

public func compose<PP: PrismType, CP: PrismType>(prism parent: PP, with child: CP)
    -> AnyPrism<PP.Source, PP.Target, CP.SourceValue, CP.TargetValue> where
    PP.SourceValue == CP.Source,
    PP.TargetValue == CP.Target {
        return AnyPrism<PP.Source, PP.Target, CP.SourceValue, CP.TargetValue>(
            tryGet: { source in parent.tryGet(from: source).flatMap(child.tryGet(from:)) },
            reset: { value in parent.reset(to: child.reset(to: value)) },
            map: { source, transform in
                parent.map(from: source) { value in child.map(from: value, over: transform) }
        })
}

public func compose<PP: PrismType, CP: PrismType>(prism parent: PP, with child: CP)
    -> AnyPrism<PP.Source, PP.Target, CP.SourceValue, CP.TargetValue> where
    PP.SourceValue == CP.Source,
    PP.TargetValue == CP.Target,
    PP.Source == PP.Target,
    CP.SourceValue == CP.TargetValue {
        let composed: AnyPrism = compose(prism: parent, with: child)
        return Prism<PP.Source, CP.SourceValue>(tryGet: composed._tryGet, reset: composed._reset)
}
