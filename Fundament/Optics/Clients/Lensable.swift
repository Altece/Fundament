import Foundation

public typealias Lensable = Traversable & Gettable & Settable

extension Settable where Self: Lensable {
    public subscript<L: LensType>(over lens: L) -> L.SourceValue
        where Self == L.Source, Self == L.Target, L.SourceValue == L.TargetValue {
        get { return get(over: lens) }
        set { set(over: lens, to: newValue) }
    }
}
