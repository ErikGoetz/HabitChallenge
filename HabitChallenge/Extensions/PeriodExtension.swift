
import Foundation

extension Calendar {
    func startOfHabitPeriod(for frequency: HabitFrequency, from date: Date) -> Date {
        let calendar = Calendar.current

        switch frequency {
        case .daily:
            return calendar.startOfDay(for: date)
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
        }
    }
}
