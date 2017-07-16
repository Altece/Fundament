import Foundation

public typealias Lensable = Traversable & Gettable & Settable

extension Settable where Self: Lensable {
    public subscript<L: LensType>(lens: L) -> L.Aspect
        where Self == L.Source, Self == L.Target, L.Aspect == L.Detail {
        get { return get(over: lens) }
        set { set(over: lens, to: newValue) }
    }
}
