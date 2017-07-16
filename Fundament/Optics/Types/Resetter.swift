import Foundation

public protocol ResetterType {
    associatedtype Target
    associatedtype TargetValue

    func reset(to targetValue: TargetValue) -> Target
}

// MARK: - AnyResetter

public class AnyResetter<T, B>: ResetterType {
    public typealias Target = T
    public typealias TargetValue = B

    private let _reset: (TargetValue) -> Target

    public init(_ reset: @escaping (TargetValue) -> Target) {
        _reset = reset
    }

    public convenience init<M: ResetterType>(_ resetter: M)
        where Target == M.Target, TargetValue == M.TargetValue {
            self.init(resetter.reset(to:))
    }

    public func reset(to targetValue: TargetValue) -> Target {
        return _reset(targetValue)
    }
}

public typealias Resetter<Whole, Part> = AnyResetter<Whole, Part>
