import Foundation

public protocol GetterType: ReducerType {
    func get(from source: Source) -> SourceValue
}

extension GetterType {
    public func reduce<T>(from source: Source, to initialValue: T, combine: (T, SourceValue) -> T) -> T {
        return combine(initialValue, get(from: source))
    }
}

// MARK: - AnyGetter

public class AnyGetter<S, A>: GetterType {
    public typealias Source = S
    public typealias SourceValue = A

    private let _get: (Source) -> SourceValue

    public init(_ get: @escaping (Source) -> SourceValue) {
        _get = get
    }

    public convenience init<G: GetterType>(_ getter: G)
        where Source == G.Source, SourceValue == G.SourceValue {
            self.init(getter.get(from:))
    }

    public func get(from source: Source) -> SourceValue {
        return _get(source)
    }
}

public typealias Getter<Whole, Part> = AnyGetter<Whole, Part>
