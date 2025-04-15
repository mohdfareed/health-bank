import Foundation
import SwiftData
import SwiftUI

@propertyWrapper struct UnitMeasurement<Unit: DataUnit>: DynamicProperty {
    @AppStorage var appUnit: Unit
    @Binding var value: Double

    var wrappedValue: Measurement<Unit.DimensionType> {
        get { Measurement(value: self.value, unit: self.appUnit.unit) }
        nonmutating set {
            self.value = newValue.converted(to: Unit.baseUnit).value
        }
    }

    var projectedValue: Binding<Measurement<Unit.DimensionType>> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    init(_ value: Binding<Double>, unit: Unit.Type) {
        self._appUnit = AppStorage(unit.key)
        self._value = value
    }
}

extension DataUnit {
    /// The settings key for the user's chosen unit.
    static var key: Settings<Self> {
        Settings<Self>(Self.id, default: Self())
    }

    /// The base unit for the dimension.
    static var baseUnit: DimensionType {
        Self.DimensionType.baseUnit()
    }

    /// Create a measurement binding about the value binding.
    static func binding(
        _ value: Binding<Double>
    ) -> Binding<Measurement<Self.DimensionType>> {
        let measurement = UnitMeasurement(value, unit: Self.self)
        return measurement.projectedValue
    }
}

enum WeightUnit: DataUnit {
    case kilograms, pounds
    init() { self = .kilograms }
}

extension WeightUnit {
    typealias DimensionType = UnitMass
    static let id: String = "WeightUnit"

    var unit: UnitMass {
        switch self {
        case .kilograms:
            return UnitMass.kilograms
        case .pounds:
            return UnitMass.pounds
        }
    }
}
