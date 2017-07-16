import Foundation

public protocol Reduceable {}
extension Reduceable {
    public func reduce<R: ReducerType, U>(over reducer: R,
                                          to initialValue: U,
                                          _ combine: (U, R.SourceValue) -> U) -> U
        where Self == R.Source {
            return reducer.reduce(from: self, to: initialValue, combine: combine)
    }

    public subscript<R: ReducerType>(try reducer: R) -> R.SourceValue? where Self == R.Source {
        get { return reducer.tryGet(from: self) }
    }
}
