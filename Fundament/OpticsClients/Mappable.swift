import Foundation

public protocol Mappable {}
extension Mappable {
    public func map<M: MapperType>(over mapper: M, _ transform: (M.Aspect) -> M.Detail) -> Self
        where Self == M.Source, Self == M.Target {
            return mapper.map(from: self, over: transform)
    }
}
