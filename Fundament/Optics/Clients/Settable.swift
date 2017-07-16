import Foundation

public protocol Settable {}
extension Settable {
    public func setting<S: SetterType>(over setter: S, to newValue: S.TargetValue) -> S.Target
        where Self == S.Source {
            return setter.set(from: self, to: newValue)
    }

    public mutating func set<S: SetterType>(over setter: S, to newValue: S.TargetValue)
        where Self == S.Source, Self == S.Target {
            self = setting(over: setter, to: newValue)
    }
}
