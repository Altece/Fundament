import Foundation

public protocol MakerType {
    associatedtype Target
    associatedtype Detail

    func make(from detail: Detail) -> Target
}

// MARK: - AnyMaker

public class AnyMaker<T, B>: MakerType {
    public typealias Target = T
    public typealias Detail = B

    private let _make: (Detail) -> Target

    public init(_ make: @escaping (Detail) -> Target) {
        _make = make
    }

    public convenience init<M: MakerType>(_ maker: M)
        where Target == M.Target, Detail == M.Detail {
            self.init(maker.make(from:))
    }

    public func make(from detail: Detail) -> Target {
        return _make(detail)
    }
}

public typealias Maker<Whole, Part> = AnyMaker<Whole, Part>
