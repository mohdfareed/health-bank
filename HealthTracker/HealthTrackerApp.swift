import OSLog
import SwiftData
import SwiftUI

@main struct HealthTrackerApp: App {
	internal let logger = AppLogger.new(for: Self.self)
	var container: ModelContainer

	static let appModels: [any PersistentModel.Type] = [
        PreviewModel.self,
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
	var body: some View {
		VStack {
            PreviewSettings()
            PreviewSingleton()
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
