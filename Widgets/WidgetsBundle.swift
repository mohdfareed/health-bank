import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        BudgetWidgetKit()
        MacrosWidgetKit()
        OverviewWidgetKit()
    }
}
