import OSLog
import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appDomain: String = Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"

@main struct HealthTrackerApp: App {
	internal let logger = AppLogger.new(for: Self.self)
	var localContainer: ModelContainer
	var remoteContext: RemoteContext

	static let appModels: [any PersistentModel.Type] = [
		CalorieBudget.self
	]

	static let dataModels: [any (DataRecord & PersistentModel).Type] = [
		CalorieConsumed.self,
		CalorieBurned.self,
	]

	init() {
		self.localContainer = try! ModelContainer(
			for: Schema(Self.appModels + Self.dataModels),
			configurations: ModelConfiguration()
		)
		self.remoteContext = RemoteContext(
			stores: [
				SimulatedStore(using: [])
			]
		)
	}

	var body: some Scene {
		WindowGroup {
			AppPreview()
				.modelContainer(self.localContainer)
				.remoteContext(self.remoteContext)
			// DashboardView()
			// 	.modelContainer(AppDataStore.container)
			// 	.remoteContext(self.remoteContext)
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
			PreviewTableEditor(
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
			try! .init(
				for: Schema(
					HealthTrackerApp.appModels + HealthTrackerApp.dataModels
				),
				configurations: .init(isStoredInMemoryOnly: true)
			)
		)
		.remoteContext(.init(stores: [SimulatedStore()]))
		.preferredColorScheme(.dark)
}
