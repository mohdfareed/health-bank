import Combine
import SwiftData
import SwiftUI

final class LogEntryVM: ObservableObject {
    @Published var entryDate: Date = Date.now
    @Published var calorieAmount: Int = 0
    @Published var errorMessage: String? = nil

    private let caloriesService: CaloriesService

    init(caloriesService: CaloriesService) {
        self.caloriesService = caloriesService
    }

    func submitEntry() {
        let entry = CalorieEntry(calorieAmount, on: entryDate)
        self.submit(entry)
        self.clear()
    }

    private func submit(_ entry: CalorieEntry) {
        self.caloriesService.log(entry)
    }

    private func clear() {
        entryDate = Date.now
        calorieAmount = 0
        errorMessage = nil
    }
}
