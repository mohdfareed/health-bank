import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appDomain: String = Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"

@main struct HealthTrackerApp: App {
	internal let logger = AppLogger.new(for: Self.self)

	let models: [any PersistentModel.Type] = [
		CalorieBudget.self,
		ConsumedCalorie.self,
		BurnedCalorie.self,
	]

	var localContainer: ModelContainer
	var remoteContext: RemoteContext
	var unitService: UnitService = .init(providers: [:])

	init() {
		self.localContainer = try! ModelContainer(
			for: Schema(self.models),
			configurations: ModelConfiguration()
		)
		self.remoteContext = RemoteContext(
			stores: [
				SimulatedStore(using: [])
			]
		)
		self.unitService = UnitService(providers: [:])
	}

	var body: some Scene {
		WindowGroup {
			// DashboardView()
			// 	.modelContainer(self.localContainer)
			// 	.remoteContext(self.remoteContext)
			// 	.unitService(self.unitService)
		}
	}
}

#Preview {
	let app = HealthTrackerApp()
	PreviewSingletonView()
		.modelContainer(app.localContainer)
		.remoteContext(app.remoteContext)
		.unitService(app.unitService)
		.preferredColorScheme(.dark)
}
