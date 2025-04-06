import OSLog
import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appDomain: String = Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"

@main struct HealthTrackerApp: App {
	internal let logger = AppLogger.new(for: Self.self)
	var container: ModelContainer

	static let appModels: [any PersistentModel.Type] = [
		CalorieBudget.self
	]

	static let dataModels: [any DataResource.Type] = [
		CaloriesConsumed.self,
		CaloriesBurned.self,
		CalorieProteins.self,
		CalorieFat.self,
		CalorieCarbs.self,
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
			AppPreview().modelContainer(self.container)
			// DashboardView().modelContainer(AppDataStore.container)
		}
	}
}

struct AppPreview: View {
	@Query.Settings(AppSettings.dailyCalorieBudget)
	var dailyCalorieBudget: CalorieBudget.ID?

	init() {
		UserDefaults.standard.removePersistentDomain(forName: appDomain)
	}

	var body: some View {
		VStack {
			PreviewSettings("HealthKit", key: AppSettings.healthKit).padding()
			if let singletonID = self.dailyCalorieBudget {
				PreviewSingleton<CalorieBudget>(
					id: #Predicate { $0.id == singletonID },
					editor: { $0.dailyCalories = Double.random(in: 0..<10000) }
				).padding()
			}
			TableEditor(
				factory: { CalorieBudget() },
				editor: {
					self.dailyCalorieBudget = $0.id
					$0.dailyCalories = Double.random(in: 0..<10000)
				}
			) { item in
				cardRow(
					"Calories",
					value: "\(String(describing: item.dailyCalories))"
				)
			}
			.cornerRadius(25)
		}
	}
}

#Preview {
	AppPreview()
		.modelContainer(
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
		)
		.preferredColorScheme(.dark)
}
