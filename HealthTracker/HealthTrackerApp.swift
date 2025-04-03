import OSLog
import SwiftData
import SwiftUI

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
			AppView().modelContainer(self.container)
			// DashboardView().modelContainer(AppDataStore.container)
		}
	}
}

struct AppView: View {
//	@Query.Settings(AppSettings.dailyCalorieBudget)
//	var dailyCalorieBudget: PersistentIdentifier?

	var body: some View {
		VStack {
			PreviewSettings(key: AppSettings.healthKit).padding()
//			PreviewSingleton(id: self.dailyCalorieBudget).padding()
		}
	}
}

#Preview {
	AppView()
		.modelContainer(
			try! ModelContainer(
				for: Schema(
					HealthTrackerApp.appModels + []
				),
				configurations: ModelConfiguration(
					isStoredInMemoryOnly: true
				),
				ModelConfiguration(
					isStoredInMemoryOnly: true
				)
			)
		)
		// .modelContainer(
		// 	for: CalorieBudget.self, inMemory: true
		// )
		.preferredColorScheme(.dark)
		.resetSettings()
}
