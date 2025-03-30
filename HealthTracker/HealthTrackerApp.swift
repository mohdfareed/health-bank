import OSLog
import SwiftData
import SwiftUI

@main struct HealthTrackerApp: App {
	internal let logger = AppLogger.new(for: Self.self)
	var container: ModelContainer

	static let appModels: [any PersistentModel.Type] = [
		CaloriesBudget.self
	]

	static let dataModels: [any DataModel.Type] = [
		CaloriesConsumed.self
		//        CaloriesBurned.self,
		//        CalorieProteins.self,
		//        CalorieFat.self,
		//        CalorieCarbs.self,
	]

	init() {
		self.container = try! ModelContainer(
			for: Schema(Self.appModels + Self.dataModels),
			configurations: ModelConfiguration(),
			ModelConfiguration(
				isStoredInMemoryOnly: true
			)
		)
	}

	var body: some Scene {
		WindowGroup {
			AppView().modelContainer(self.container)
			// DashboardView().modelContainer(AppDataStore.container)
		}
	}
}

struct AppView: View {
	@Environment(\.modelContext) var context: ModelContext

	@Query.Settings(AppSettings.enableHealthKit)
	var enableHealthKit: Bool?

	@Query.Settings(AppSettings.enableHealthKit)
	var enableHealthKit2: Bool?

	@Query.Singleton var budget: CaloriesBudget?
	@Query var calories: [CaloriesConsumed]
	@Query var items: [PreviewModel]

	init() {
		self._items = Query(sort: \.persistentModelID, order: .forward)
	}

	var body: some View {
		VStack {
			Text("Health Tracker")
				.font(.largeTitle)
				.padding()
			Toggle(isOn: $enableHealthKit.defaulted(to: false)) {
				Text("Enable HealthKit")
			}.padding()
			Text("healthKit status: \(enableHealthKit ?? false)")
				.padding()

			TableEditor(
				factory: {
					CaloriesConsumed(
						Double.random(in: 0..<5000), on: Date(),
						from: .all.randomElement()!
					)
				},
				modifier: { $0.calories = Double.random(in: 0..<5000) }
			) {
				row("Calories", value: "\($0.calories)")
				row("Date", value: $0.date.formatted())
				row("Source", value: String(describing: $0.source))
				row("HealthKit", value: "\(enableHealthKit2 ?? false)")
			}

		}
	}
}

#Preview {
	AppView().modelContainer(
		try! ModelContainer(
			for: Schema(
				HealthTrackerApp.appModels + HealthTrackerApp.dataModels
			),
			configurations: ModelConfiguration(
				isStoredInMemoryOnly: true
			),
			ModelConfiguration(
				isStoredInMemoryOnly: true
			)
		)
	).preferredColorScheme(.dark)
}
