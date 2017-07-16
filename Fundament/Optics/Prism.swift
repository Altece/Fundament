import Foundation

public typealias PrismType = TraversalType & MakerType

extension MakerType where Self: PrismType, Self.Source == Self.Target {
    public func map(from source: Source, over transform: (Aspect) -> Detail) -> Target {
        return tryGet(from: source).map(transform).map(make(from:)) ?? source
    }
}

extension ReducerType where Self: PrismType {
    public func reduce<T>(from source: Source, to initialValue: T, combine: (T, Aspect) -> T) -> T {
        return tryGet(from: source).map { combine(initialValue, $0) } ?? initialValue
    }
}

// MARK: - AnyPrism

public class AnyPrism<S, T, A, B>: PrismType {
    public typealias Source = S
    public typealias Target = T
    public typealias Aspect = A
    public typealias Detail = B

    private let _tryGet: (Source) -> Aspect?
    private let _make: (Detail) -> Target
    private let _map: (Source, (Aspect) -> Detail) -> Target

    public init(tryGet: @escaping (Source) -> Aspect?,
                make: @escaping (Detail) -> Target,
                map: @escaping (Source, (Aspect) -> Detail) -> Target) {
        _tryGet = tryGet
        _make = make
        _map = map
    }

    public convenience init<P: PrismType>(_ prism: P)
        where Source == P.Source, Target == P.Target, Aspect == P.Aspect, Detail == P.Detail {
            self.init(tryGet: prism.tryGet(from:),
                      make: prism.make(from:),
                      map: prism.map(from:over:))
    }

    public func tryGet(from source: Source) -> Aspect? {
        return _tryGet(source)
    }

    public func make(from detail: Detail) -> Target {
        return _make(detail)
    }

    public func map(from source: Source, over transform: (Aspect) -> Detail) -> Target {
        return _map(source, transform)
    }
}

public class Prism<Whole, Part>: AnyPrism<Whole, Whole, Part, Part> {
    public init(tryGet: @escaping (Source) -> Aspect?,
                make: @escaping (Detail) -> Target) {
        super.init(tryGet: tryGet, make: make, map: { whole, transform in
            tryGet(whole).map(transform).map(make) ?? whole
        })
    }

    public convenience init<P: PrismType>(_ prism: P)
        where Whole == P.Source, Whole == P.Target, Part == P.Aspect, Part == P.Detail {
            self.init(tryGet: prism.tryGet(from:),
                      make: prism.make(from:))
    }
}
