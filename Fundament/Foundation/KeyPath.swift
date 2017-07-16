import Foundation

// MARK: GetterType

extension KeyPath: GetterType {
    public typealias Source = Root
    public typealias SourceValue = Value

    public func get(from source: Root) -> Value {
        return source[keyPath: self]
    }
}

// MARK: - LensType

extension WritableKeyPath: MapperType, SetterType /*LensType*/ {
    public typealias Target = Root
    public typealias TargetValue = Value

    public func set(from source: Root, to targetValue: Value) -> Root {
        var source = source
        source[keyPath: self] = targetValue
        return source
    }
}
