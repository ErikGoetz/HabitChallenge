//Storage of the Habitdata

import Foundation

final class HabitStore: ObservableObject {
    @Published var habits: [HabitItem] = [] {
        didSet {
            saveHabits()
        }
    }

    private let habitsKey = "savedHabits"
    private let lastDailyResetKey = "lastDailyResetDate"
    private let lastWeeklyResetKey = "lastWeeklyResetDate"

    init() {
        loadHabits()
        ensureResetDatesExist()
        resetHabitsIfNeeded()
    }

    func addHabit(_ habit: HabitItem) {
        habits.append(habit)
    }

    func updateHabit(_ updatedHabit: HabitItem) {
        guard let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) else { return }
        habits[index] = updatedHabit
    }

    func deleteHabit(_ habit: HabitItem) {
        habits.removeAll { $0.id == habit.id }
    }

    func toggleBinaryHabit(_ habitID: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        guard habits[index].type == .binary else { return }

        habits[index].isCompleted.toggle()
        habits[index].currentValue = habits[index].isCompleted ? 1 : 0
    }

    func updateMeasurableProgress(for habitID: UUID, to newValue: Int) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        guard habits[index].type == .measurable else { return }

        habits[index].currentValue = newValue
        habits[index].isCompleted = newValue >= habits[index].targetValue
    }

    func resetHabitsIfNeeded(now: Date = Date()) {
        let defaults = UserDefaults.standard
        let calendar = Calendar.current

        let lastDailyResetDate = defaults.object(forKey: lastDailyResetKey) as? Date
        let lastWeeklyResetDate = defaults.object(forKey: lastWeeklyResetKey) as? Date

        let shouldResetDaily = shouldResetDailyHabits(
            lastDailyResetDate: lastDailyResetDate,
            now: now,
            calendar: calendar
        )

        let shouldResetWeekly = shouldResetWeeklyHabits(
            lastWeeklyResetDate: lastWeeklyResetDate,
            now: now,
            calendar: calendar
        )

        var updatedHabits = habits
        var didChange = false

        if shouldResetDaily {
            for index in updatedHabits.indices where updatedHabits[index].frequency == .daily {
                updatedHabits[index].currentValue = 0
                updatedHabits[index].isCompleted = false
            }

            defaults.set(now, forKey: lastDailyResetKey)
            didChange = true
        }

        if shouldResetWeekly {
            for index in updatedHabits.indices where updatedHabits[index].frequency == .weekly {
                updatedHabits[index].currentValue = 0
                updatedHabits[index].isCompleted = false
            }

            defaults.set(now, forKey: lastWeeklyResetKey)
            didChange = true
        }

        if didChange {
            habits = updatedHabits
        }
    }

    private func shouldResetDailyHabits(
        lastDailyResetDate: Date?,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        guard let lastDailyResetDate else { return false }
        return !calendar.isDate(lastDailyResetDate, inSameDayAs: now)
    }

    private func shouldResetWeeklyHabits(
        lastWeeklyResetDate: Date?,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        guard let lastWeeklyResetDate else { return false }
        return !calendar.isDate(lastWeeklyResetDate, equalTo: now, toGranularity: .weekOfYear)
    }

    private func ensureResetDatesExist() {
        let defaults = UserDefaults.standard
        let now = Date()

        if defaults.object(forKey: lastDailyResetKey) == nil {
            defaults.set(now, forKey: lastDailyResetKey)
        }

        if defaults.object(forKey: lastWeeklyResetKey) == nil {
            defaults.set(now, forKey: lastWeeklyResetKey)
        }
    }

    private func saveHabits() {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: habitsKey)
        } catch {
            print("Fehler beim Speichern der Habits: \(error)")
        }
    }

    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: habitsKey) else { return }

        do {
            habits = try JSONDecoder().decode([HabitItem].self, from: data)
        } catch {
            print("Fehler beim Laden der Habits: \(error)")
        }
    }
}
