import Foundation

public protocol Resettable {}
extension Resettable {
    public func resetting<M: MakerType>(over maker: M, to targetValue: M.TargetValue) -> M.Target {
        return maker.make(from: targetValue)
    }

    public mutating func reset<M: MakerType>(over maker: M, to targetValue: M.TargetValue)
        where Self == M.Target {
            self = resetting(over: maker, to: targetValue)
    }
}
