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

	//	static let dataModels: [any DataModel.Type] = [
	//		CaloriesConsumed.self
	//		//        CaloriesBurned.self,
	//		//        CalorieProteins.self,
	//		//        CalorieFat.self,
	//		//        CalorieCarbs.self,
	//	]

	init() {
		self.container = try! ModelContainer(
			for: Schema(Self.appModels + []),
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
	var dailyCalorieBudget: PersistentIdentifier?

	init() {
		print(AppSettings.dailyCalorieBudget)
		AppLogger.new(for: Self.self).debug("AppView initialized.")
		AppLogger.new(for: Self.self).info(
			"AppSettings.dailyCalorieBudget: \(String(describing: AppSettings.dailyCalorieBudget))"
		)
		AppLogger.new(for: Self.self).error(
			"AppSettings.dailyCalorieBudget: \(String(describing: AppSettings.dailyCalorieBudget))"
		)
		fatalError(
			"AppSettings.dailyCalorieBudget: \(String(describing: AppSettings.dailyCalorieBudget))"
		)
	}

	var body: some View {
		VStack {
			PreviewSettings("Settings", key: AppSettings.healthKit).padding()
			//			PreviewSingleton(id: self.dailyCalorieBudget).padding()
		}
	}
}

#Preview {
	AppPreview()
		//		.modelContainer(
		//			try! ModelContainer(
		//				for: Schema(
		//					HealthTrackerApp.appModels + []
		//				),
		//				configurations: ModelConfiguration(
		//					isStoredInMemoryOnly: true
		//				),
		//				ModelConfiguration(
		//					isStoredInMemoryOnly: true
		//				)
		//			)
		//		)
		.modelContainer(
			for: CalorieBudget.self, inMemory: true
		)
		.preferredColorScheme(.dark)
		.resetSettings()
}
