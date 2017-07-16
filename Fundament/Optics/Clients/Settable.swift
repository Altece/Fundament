import Foundation

public protocol Settable {}
extension Settable {
    public func setting<S: SetterType>(over setter: S, to newValue: S.Detail) -> Self
        where Self == S.Source, Self == S.Target {
            return setter.set(from: self, to: newValue)
    }

    public mutating func set<S: SetterType>(over setter: S, to newValue: S.Detail)
        where Self == S.Source, Self == S.Target {
            self = setting(over: setter, to: newValue)
    }
}
