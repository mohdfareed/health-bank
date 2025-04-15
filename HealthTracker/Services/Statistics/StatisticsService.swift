import Foundation

// MARK: Errors
// ============================================================================

enum DataError: Error {
    case InvalidData(String)
    case InvalidDateRange(from: Date, to: Date)
    case InvalidModel(String)
    case DataTypeMismatch(expected: String, actual: String)
}

// MARK: Statistics
// ============================================================================

typealias Advancer<T: Strideable> = (T, T.Stride) -> T

extension Sequence {
    func points<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    func points<X, Y>(
        x: KeyPath<Element, X>, y: KeyPath<Element, Y>
    ) -> [(x: X, y: Y)] {
        return map { ($0[keyPath: x], $0[keyPath: y]) }
    }
}

extension Sequence where Element: AdditiveArithmetic {
    /// The sum of all data points.
    func sum() -> Element {
        self.reduce(.zero, +)
    }
}

extension Sequence where Element: AdditiveArithmetic & DurationProtocol {
    /// The average of all data points.
    func average() -> Element? {
        guard self.first(where: { _ in true }) != nil else {
            return nil
        }
        let count = self.count(where: { _ in true })
        return self.sum() / count
    }
}
