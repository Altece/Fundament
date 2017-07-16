import Foundation

extension WritableKeyPath: /*LensType*/ MapperType, SetterType {
    public typealias Target = Root
    public typealias Detail = Value

    public func set(from source: Root, to detail: Value) -> Root {
        var source = source
        source[keyPath: self] = detail
        return source
    }
}

extension KeyPath: GetterType {
    public typealias Source = Root
    public typealias Aspect = Value

    public func get(from source: Root) -> Value {
        return source[keyPath: self]
    }
}
