//Storage of the Habitdata

import Foundation
import SwiftUI

final class HabitStore: ObservableObject {
    @Published var habits: [HabitItem] = [] {
        didSet {
            saveHabits()
        }
    }

    private let storageKey = "saved_habits"

    init() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        loadHabits()
    }

    private func saveHabits() {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Fehler beim Speichern der Habits: \(error)")
        }
    }

    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            habits = HabitItem.sampleData
            return
        }

        do {
            habits = try JSONDecoder().decode([HabitItem].self, from: data)
        } catch {
            print("Fehler beim Laden der Habits: \(error)")
            habits = HabitItem.sampleData
        }
    }
}
