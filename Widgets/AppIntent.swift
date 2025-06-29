import AppIntents
import HealthVaultsShared
import WidgetKit

// MARK: - Configuration Intent
// ============================================================================

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
}

// MARK: - Macro Selection Intent
// ============================================================================

/// Widget-specific macro type enum required for AppIntent configuration
enum WidgetMacroType: String, CaseIterable, AppEnum {
    case protein = "protein"
    case carbs = "carbs"
    case fat = "fat"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Macro Type")
    }

    static var caseDisplayRepresentations: [WidgetMacroType: DisplayRepresentation] {
        [
            .protein: DisplayRepresentation(title: "Protein"),
            .carbs: DisplayRepresentation(title: "Carbs"),
            .fat: DisplayRepresentation(title: "Fat"),
        ]
    }

    /// Convert to shared MacroType for use with components
    var sharedMacroType: MacroType {
        switch self {
        case .protein: return .protein
        case .carbs: return .carbs
        case .fat: return .fat
        }
    }
}

struct MacroSelectionAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Macro Selection" }
    static var description: IntentDescription { "Choose which macro to display" }

    @Parameter(title: "Macro Type", default: .protein)
    var macroType: WidgetMacroType
    
    init(macroType: WidgetMacroType = .protein) {
        self.macroType = macroType
    }
    
    init() {
        self.macroType = .protein
    }
}
