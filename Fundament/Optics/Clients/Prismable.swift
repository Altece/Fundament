import Foundation

public typealias Prismable = Traversable & Resetable

extension Resetable where Self: Traversable {
    public subscript<P: PrismType>(try prism: P) -> P.Aspect?
        where Self == P.Source, Self == P.Target, P.Aspect == P.Detail {
        get { return prism.tryGet(from: self) }
        set { if let value = newValue { reset(over: prism, to: value) } }
    }
}
