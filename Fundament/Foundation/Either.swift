import Foundation

public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

// MARK: - Map

extension Either {
    public func map<L, R>(left leftTransform: (Left) throws -> L,
                          right rightTransform: (Right) throws -> R) rethrows -> Either<L, R> {
        switch self {
        case .left(let value): return try .left(leftTransform(value))
        case .right(let value): return try .right(rightTransform(value))
        }
    }

    public func map<T>(left transform: (Left) throws -> T) rethrows -> Either<T, Right> {
        return try map(left: transform, right: { $0 })
    }

    public func map<T>(right transform: (Right) throws -> T) rethrows -> Either<Left, T> {
        return try map(left: { $0 }, right: transform)
    }
}

// MARK: - FlatMap

extension Either {
    public func flatMap<L, R>(left leftTransform: (Left) throws -> Either<L, R>,
                              right rightTransform: (Right) throws -> Either<L, R>) rethrows
        -> Either<L, R> {
            switch self {
            case .left(let value): return try leftTransform(value)
            case .right(let value): return try rightTransform(value)
            }
    }

    public func flatMap<T>(left transform: (Left) throws -> Either<T, Right>) rethrows
        -> Either<T, Right> {
            return try flatMap(left: transform, right: Either<T, Right>.right)
    }

    public func flatMap<T>(right transform: (Right) throws -> Either<Left, T>) rethrows
        -> Either<Left, T> {
            return try flatMap(left: Either<Left, T>.left, right: transform)
    }
}

// MARK: - Prisms

extension Either: Prismable {
    public static var Left: Prism<Either, Left> {
        return Prism(tryGet: {
            guard case .left(let value) = $0 else { return nil }
            return value
        }, reset: { .left($0) })
    }

    public static var Right: Prism<Either, Right> {
        return Prism(tryGet: {
            guard case .right(let value) = $0 else { return nil }
            return value
        }, reset: { .right($0) })
    }
}
