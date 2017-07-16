import Foundation

public protocol Mappable {}
extension Mappable {
    public func map<M: MapperType>(over mapper: M,
                                   _ transform: (M.SourceValue) -> M.TargetValue) -> M.Target
        where Self == M.Source {
            return mapper.map(from: self, over: transform)
    }
}
