import Foundation

public protocol MapperType {
    associatedtype Source
    associatedtype Target
    associatedtype Aspect
    associatedtype Detail

    func map(from source: Source, over transform: (Aspect) -> Detail) -> Target
}

// MARK: - AnyMapper

public class AnyMapper<S, T, A, B> {
    public typealias Source = S
    public typealias Target = T
    public typealias Aspect = A
    public typealias Detail = B
    
    private let _map: (Source, (Aspect) -> Detail) -> Target

    public init(_ map: @escaping (Source, (Aspect) -> Detail) -> Target) {
        _map = map
    }

    public convenience init<M: MapperType>(_ mapper: M)
        where Source == M.Source, Target == M.Target, Aspect == M.Aspect, Detail == M.Detail {
            self.init(mapper.map(from:over:))
    }

    public func map(from source: Source, over transform: (Aspect) -> Detail) -> Target {
        return _map(source, transform)
    }
}

public class Mapper<Whole, Part>: AnyMapper<Whole, Whole, Part, Part> {}

