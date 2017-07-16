import Foundation

public protocol Gettable {}
extension Gettable {
    public subscript<G: GetterType>(over getter: G) -> G.SourceValue where Self == G.Source {
        get { return getter.get(from: self) }
    }

    public func get<G: GetterType>(over getter: G) -> G.SourceValue
        where Self == G.Source {
            return getter.get(from: self)
    }

    public func getting<G: GetterType>(over getter: G) -> G.SourceValue
        where Self == G.Source {
            return getter.get(from: self)
    }
}
