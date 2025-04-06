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
	// @Query.Settings(AppSettings.dailyCalorieBudget)
	// var dailyCalorieBudget: PersistentIdentifier?

	init() {
		UserDefaults.standard.removePersistentDomain(forName: appDomain)
	}

	var body: some View {
		VStack {
			PreviewSettings("Settings", key: AppSettings.healthKit).padding()
			// HStack {
			// 	Text("Singleton ID").font(.headline)
			// 	Spacer()
			// 	Text(String(describing: self.dailyCalorieBudget?.hashValue))
			// }.padding(.horizontal, 32)

			// PreviewSingleton<CalorieBudget>(
			// 	id: self.dailyCalorieBudget,
			// 	factory: { CalorieBudget() },
			// 	editor: { $0.dailyCalories = Double.random(in: 0..<10000) }
			// ).padding()

			TableEditor(
				factory: { CalorieBudget() },
				editor: { $0.dailyCalories = Double.random(in: 0..<10000) }
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
}
