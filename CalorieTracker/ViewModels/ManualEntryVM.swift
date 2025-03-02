import Combine
import OSLog
import SwiftData
import SwiftUI

@Observable
final class LogEntryVM {
    var entryDate: Date = Date.now
    var calorieAmount: Int? = nil

    var canSave: Bool {
        calorieAmount != nil
    }

    private let caloriesService: CaloriesService

    init(caloriesService: CaloriesService) {
        self.caloriesService = caloriesService
    }

    func submit() {
        guard let calorieAmount = calorieAmount else {
            return
        }

        let entry = CalorieEntry(calorieAmount, on: entryDate)
        self.create(entry)
        self.clear()
    }

    private func create(_ entry: CalorieEntry) {
        self.caloriesService.create(entry)
    }

    private func clear() {
        entryDate = Date.now
        calorieAmount = nil
    }
}
