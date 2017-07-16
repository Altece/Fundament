import Foundation

public typealias Prismable = Traversable & Resettable

extension Resettable where Self: Traversable {
    public subscript<P: PrismType>(try prism: P) -> P.SourceValue?
        where Self == P.Source, Self == P.Target, P.SourceValue == P.TargetValue {
        get { return prism.tryGet(from: self) }
        set { if let value = newValue { reset(over: prism, to: value) } }
    }
}
