import Foundation

typealias Advancer<T: Strideable> = (T, T.Stride) -> T

// MARK: Statistics

extension Sequence {
    func points<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }

    func points<X, Y>(x: KeyPath<Element, X>, y: KeyPath<Element, Y>) -> [any DataPoint<X, Y>] {
        return map { GenericPoint(x: $0[keyPath: x], y: $0[keyPath: y]) }
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

// MARK: Data Binning

extension Collection where Element: DataPoint, Element.X: Strideable {
    /// Bin the data points into the range.
    func bin(
        _ count: Element.X.Stride,
        using advance: Advancer<Element.X> = { $0.advanced(by: $1) }
    ) -> [(Range<Element.X>, values: [Element.Y])]
    where Element.X.Stride: BinaryFloatingPoint {
        guard
            let minValue = self.points(\.x).min(),
            let maxValue = self.points(\.x).max()
        else {
            return []
        }

        let step = minValue.distance(to: maxValue) / count
        return self.bin(step: step, using: advance)
    }

    /// Bin the data points into the range.
    func bin(
        step: Element.X.Stride, anchor: Element.X? = nil,
        using advance: Advancer<Element.X> = { $0.advanced(by: $1) }
    ) -> [(Range<Element.X>, values: [Element.Y])] {
        guard
            let minValue = self.points(\.x).min(),
            let maxValue = self.points(\.x).max()
        else {
            return []
        }

        let inTimeRange = {
            if step > 0 {
                return $0 > minValue
            } else {
                return $0 < maxValue
            }
        }

        // Fix the start to be before the min value
        var start = anchor ?? minValue
        while inTimeRange(start) {
            start = advance(start, -step)
        }

        // Generate the bins
        let bins = (start...maxValue).generateBins(step: step, using: advance)
        var binnedData = bins.map { (range: $0, values: [Element.Y]()) }

        // Split the data into the bins
        for point in self {
            if let index = bins.firstIndex(where: { $0.contains(point.x) }) {
                binnedData[index].values.append(point.y)
            }
        }
        return binnedData
    }
}

extension ClosedRange where Bound: Strideable {
    /// Generate data bins out of a range with a given step.
    func generateBins(
        step: Bound.Stride, using advance: Advancer<Bound>
    ) -> [Range<Bound>] {
        var bins: [Range<Bound>] = []
        var current = self.lowerBound
        while current < self.upperBound {
            let next = advance(current, step)
            bins.append(current..<next)
            current = next
        }
        return bins
    }
}

// MARK: Errors

enum DataError: Error {
    case InvalidData(String)
    case InvalidDateRange(from: Date, to: Date)
    case InvalidModel(String)
    case DataTypeMismatch(expected: String, actual: String)
}
