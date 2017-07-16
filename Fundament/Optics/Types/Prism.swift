import Foundation

public typealias PrismType = TraversalType & ResetType

extension ResetType where Self: PrismType, Self.Source == Self.Target {
    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return tryGet(from: source).map(transform).map(reset(to:)) ?? source
    }
}

extension ReducerType where Self: PrismType {
    public func reduce<T>(from source: Source, to initialValue: T, combine: (T, SourceValue) -> T) -> T {
        return tryGet(from: source).map { combine(initialValue, $0) } ?? initialValue
    }
}

// MARK: - AnyPrism

public class AnyPrism<S, T, A, B>: PrismType {
    public typealias Source = S
    public typealias Target = T
    public typealias SourceValue = A
    public typealias TargetValue = B

    private let _tryGet: (Source) -> SourceValue?
    private let _make: (TargetValue) -> Target
    private let _map: (Source, (SourceValue) -> TargetValue) -> Target

    public init(tryGet: @escaping (Source) -> SourceValue?,
                make: @escaping (TargetValue) -> Target,
                map: @escaping (Source, (SourceValue) -> TargetValue) -> Target) {
        _tryGet = tryGet
        _make = make
        _map = map
    }

    public convenience init<P: PrismType>(_ prism: P)
        where Source == P.Source, Target == P.Target, SourceValue == P.SourceValue, TargetValue == P.TargetValue {
            self.init(tryGet: prism.tryGet(from:),
                      make: prism.reset(to:),
                      map: prism.map(from:over:))
    }

    public func tryGet(from source: Source) -> SourceValue? {
        return _tryGet(source)
    }

    public func reset(to targetValue: TargetValue) -> Target {
        return _make(targetValue)
    }

    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return _map(source, transform)
    }
}

public class Prism<Whole, Part>: AnyPrism<Whole, Whole, Part, Part> {
    public init(tryGet: @escaping (Source) -> SourceValue?,
                make: @escaping (TargetValue) -> Target) {
        super.init(tryGet: tryGet, make: make, map: { whole, transform in
            tryGet(whole).map(transform).map(make) ?? whole
        })
    }

    public convenience init<P: PrismType>(_ prism: P)
        where Whole == P.Source, Whole == P.Target, Part == P.SourceValue, Part == P.TargetValue {
            self.init(tryGet: prism.tryGet(from:),
                      make: prism.reset(to:))
    }
}
