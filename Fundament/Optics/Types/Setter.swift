import Foundation

public protocol SetterType {
    associatedtype Source
    associatedtype Target
    associatedtype Detail

    func set(from source: Source, to detail: Detail) -> Target
}

// MARK: - AnySetter

public class AnySetter<S, T, B>: SetterType {
    public typealias Source = S
    public typealias Target = T
    public typealias Detail = B

    private let _set: (Source, Detail) -> Target

    public init(_ set: @escaping (Source, Detail) -> Target) {
        _set = set
    }

    public convenience init<S: SetterType>(_ setter: S)
        where Source == S.Source, Target == S.Target, Detail == S.Detail {
            self.init(setter.set(from:to:))
    }

    public func set(from source: Source, to detail: Detail) -> Target {
        return _set(source, detail)
    }
}

public class Setter<Whole, Part>: AnySetter<Whole, Whole, Part> {}
