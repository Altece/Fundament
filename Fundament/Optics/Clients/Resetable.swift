import Foundation

public protocol Resetable {}
extension Resetable {
    public func resetting<M: MakerType>(over maker: M, to detail: M.Detail) -> Self
        where Self == M.Target {
            return maker.make(from: detail)
    }

    public mutating func reset<M: MakerType>(over maker: M, to detail: M.Detail)
        where Self == M.Target {
            self = resetting(over: maker, to: detail)
    }
}
