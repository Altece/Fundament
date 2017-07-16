import Foundation

public protocol SetterType {
    associatedtype Source
    associatedtype Target
    associatedtype TargetValue

    func set(from source: Source, to targetValue: TargetValue) -> Target
}

// MARK: - AnySetter

public class AnySetter<S, T, B>: SetterType {
    public typealias Source = S
    public typealias Target = T
    public typealias TargetValue = B

    private let _set: (Source, TargetValue) -> Target

    public init(_ set: @escaping (Source, TargetValue) -> Target) {
        _set = set
    }

    public convenience init<S: SetterType>(_ setter: S)
        where Source == S.Source, Target == S.Target, TargetValue == S.TargetValue {
            self.init(setter.set(from:to:))
    }

    public func set(from source: Source, to targetValue: TargetValue) -> Target {
        return _set(source, targetValue)
    }
}

public class Setter<Whole, Part>: AnySetter<Whole, Whole, Part> {}
