import Foundation

// MARK: Reduce

extension Optional {
    public func reduce<T>(_ initialValue: T, _ combine: (T, Wrapped) -> T) -> T {
        return self.map { combine(initialValue, $0) } ?? initialValue
    }
}

// MARK: Prisms

extension Optional: Prismable {
    public static var Some: Prism<Optional, Wrapped> {
        return Prism(tryGet: { $0 }, reset: { $0 })
    }

    public static var None: Prism<Optional, ()> {
        return Prism(tryGet: {
            guard case nil = $0 else { return nil }
            return ()
        }, reset: { _ in nil })
    }
}
