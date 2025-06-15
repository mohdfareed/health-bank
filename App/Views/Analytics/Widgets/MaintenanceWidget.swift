import Charts
import SwiftData
import SwiftUI

// // MARK: - Maintenance Discovery Widget
// // ============================================================================

// struct MaintenanceWidget: View {
//     let healthKitService: HealthKitService
//     let analyticsService: AnalyticsService

//     @State private var maintenanceData: MaintenanceData?
//     @State private var isLoading = true

//     struct MaintenanceData {
//         let estimatedMaintenance: Double
//         let currentBudget: Double
//         let deficitSurplus: Double
//         let confidence: String
//     }

//     var body: some View {
//         DashboardCard(
//             title: "Maintenance Discovery",
//             icon: Image(systemName: "target"),
//             color: .blue
//         ) {
//             if isLoading {
//                 ProgressView()
//                     .frame(maxWidth: .infinity, minHeight: 100)
//             } else if let data = maintenanceData {
//                 MaintenanceContent(data: data)
//             } else {
//                 Text("Insufficient data for maintenance estimation")
//                     .foregroundColor(.secondary)
//                     .multilineTextAlignment(.center)
//             }
//         } destination: {
//         }
//         .task {
//             await loadMaintenanceData()
//         }
//     }

//     @ViewBuilder
//     private func MaintenanceContent(data: MaintenanceData) -> some View {
//         VStack(alignment: .leading, spacing: 12) {
//             // Estimated maintenance
//             HStack {
//                 Text("\(Int(data.estimatedMaintenance))")
//                     .font(.largeTitle)
//                     .fontWeight(.bold)
//                     .foregroundColor(.primary)

//                 Text("kcal/day")
//                     .font(.caption)
//                     .foregroundColor(.secondary)

//                 Spacer()
//             }

//             // Deficit/Surplus
//             HStack {
//                 Image(systemName: data.deficitSurplus < 0 ? "arrow.down" : "arrow.up")
//                     .foregroundColor(data.deficitSurplus < 0 ? .green : .red)

//                 Text(
//                     "\(abs(Int(data.deficitSurplus))) kcal \(data.deficitSurplus < 0 ? "deficit" : "surplus")"
//                 )
//                 .font(.headline)
//                 .foregroundColor(data.deficitSurplus < 0 ? .green : .red)

//                 Spacer()
//             }

//             Text("Confidence: \(data.confidence)")
//                 .font(.caption)
//                 .foregroundColor(.secondary)
//         }
//     }

//     private func loadMaintenanceData() async {
//         isLoading = true
//         defer { isLoading = false }

//         let analytics = AnalyticsService()

//         let endDate = Date()
//         let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!

//         // Get weight and calorie data
//         let weightData = await healthKitService.fetchStatistics(
//             for: .bodyMass,
//             from: startDate,
//             to: endDate,
//             interval: .daily,
//             options: .discreteAverage
//         )

//         let calorieData = await healthKitService.fetchStatistics(
//             for: .dietaryCalories,
//             from: startDate,
//             to: endDate,
//             interval: .daily,
//             options: .cumulativeSum
//         )

//         guard
//             let estimatedMaintenance = await analytics.estimateMaintenanceCalories(
//                 weightData: weightData,
//                 calorieData: calorieData,
//                 weightWindowDays: 14,
//                 calorieWindowDays: 7
//             )
//         else {
//             return
//         }

//         let currentBudget = 2000.0  // This should come from settings
//         let deficitSurplus = currentBudget - estimatedMaintenance

//         // Calculate confidence based on data availability
//         let confidence: String
//         if calorieData.count >= 7 && weightData.count >= 14 {
//             confidence = "High"
//         } else if calorieData.count >= 5 && weightData.count >= 10 {
//             confidence = "Medium"
//         } else {
//             confidence = "Low"
//         }

//         maintenanceData = MaintenanceData(
//             estimatedMaintenance: estimatedMaintenance,
//             currentBudget: currentBudget,
//             deficitSurplus: deficitSurplus,
//             confidence: confidence
//         )
//     }
// }
