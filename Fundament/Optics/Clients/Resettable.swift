import Foundation

public protocol Resettable {}
extension Resettable {
    public func resetting<R: ResetterType>(over resetter: R,
                                           to targetValue: R.TargetValue) -> R.Target {
        return resetter.reset(to: targetValue)
    }

    public mutating func reset<R: ResetterType>(over resetter: R, to targetValue: R.TargetValue)
        where Self == R.Target {
            self = resetting(over: resetter, to: targetValue)
    }
}
