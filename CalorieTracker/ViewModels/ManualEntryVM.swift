import Combine
import SwiftData
import SwiftUI

final class LogEntryVM: ObservableObject {
    @Published var entryDate: Date = Date.now
    @Published var calorieAmount: Int? = nil

    @Published var canSave: Bool = false
    @Published var errorMessage: String? = nil

    private let caloriesService: CaloriesService

    init(caloriesService: CaloriesService) {
        self.caloriesService = caloriesService
    }

    func onDataChange() {
        canSave = calorieAmount != nil
    }

    func submitEntry() {
        guard let calorieAmount = calorieAmount else {
            self.errorMessage = "Please enter a calorie amount."
            return
        }

        let entry = CalorieEntry(calorieAmount, on: entryDate)
        self.submit(entry)
        self.clear()
    }

    private func submit(_ entry: CalorieEntry) {
        self.caloriesService.log(entry)
    }

    private func clear() {
        entryDate = Date.now
        calorieAmount = nil

        canSave = false
        errorMessage = nil
    }
}
