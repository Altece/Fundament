import Foundation

public protocol GetterType: ReducerType {
    func get(from source: Source) -> Aspect
}

extension GetterType {
    public func reduce<T>(from source: Source, to initialValue: T, combine: (T, Aspect) -> T) -> T {
        return combine(initialValue, get(from: source))
    }
}

// MARK: - AnyGetter

public class AnyGetter<S, A>: GetterType {
    public typealias Source = S
    public typealias Aspect = A

    private let _get: (Source) -> Aspect

    public init(_ get: @escaping (Source) -> Aspect) {
        _get = get
    }

    public convenience init<G: GetterType>(_ getter: G)
        where Source == G.Source, Aspect == G.Aspect {
            self.init(getter.get(from:))
    }

    public func get(from source: Source) -> Aspect {
        return _get(source)
    }
}

public typealias Getter<Whole, Part> = AnyGetter<Whole, Part>
