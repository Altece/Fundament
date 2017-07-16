import Foundation

public protocol MapperType: SetterType {
    associatedtype SourceValue

    func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target
}

extension MapperType {
    public func set(from source: Source, to targetValue: TargetValue) -> Target {
        return map(from: source) { _ in targetValue }
    }
}

// MARK: - AnyMapper

public class AnyMapper<S, T, A, B> {
    public typealias Source = S
    public typealias Target = T
    public typealias SourceValue = A
    public typealias TargetValue = B
    
    private let _map: (Source, (SourceValue) -> TargetValue) -> Target

    public init(_ map: @escaping (Source, (SourceValue) -> TargetValue) -> Target) {
        _map = map
    }

    public convenience init<M: MapperType>(_ mapper: M)
        where Source == M.Source, Target == M.Target, SourceValue == M.SourceValue, TargetValue == M.TargetValue {
            self.init(mapper.map(from:over:))
    }

    public func map(from source: Source, over transform: (SourceValue) -> TargetValue) -> Target {
        return _map(source, transform)
    }
}

public class Mapper<Whole, Part>: AnyMapper<Whole, Whole, Part, Part> {}

