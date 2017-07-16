import Foundation

public typealias IsomorphType = LensType & PrismType

extension MakerType where Self: IsomorphType, Self.Source == Self.Target {
    public func map(from source: Source, over transform: (Aspect) -> Detail) -> Target {
        return set(from: source, to: transform(get(from: source)))
    }
}

extension SetterType where Self: IsomorphType {
    public func set(from source: Source, to detail: Detail) -> Target {
        return make(from: detail)
    }
}

// MARK: - AnyIsomorph

public class AnyIsomorph<S, T, A, B>: IsomorphType {
    public typealias Source = S
    public typealias Target = T
    public typealias Aspect = A
    public typealias Detail = B

    private let _get: (Source) -> Aspect
    private let _make: (Detail) -> Target

    public init(get: @escaping (Source) -> Aspect, make: @escaping (Detail) -> Target) {
        _get = get
        _make = make
    }

    public convenience init<I: IsomorphType>(_ isomorph: I)
        where Source == I.Source, Target == I.Target, Aspect == I.Aspect, Detail == I.Detail {
            self.init(get: isomorph.get(from:), make: isomorph.make(from:))
    }

    public func get(from source: Source) -> Aspect {
        return _get(source)
    }

    public func make(from detail: Detail) -> Target {
        return _make(detail)
    }
}

public class Isomorph<Whole, Part>: AnyIsomorph<Whole, Whole, Part, Part> {}
