//
//  HabitItem.swift
//  HabitChallenge
//
//  Created by Erik Götz on 03.06.26.
//
//  Key Model of the Habits, also some Sampledata to try things out
//

import SwiftUI

struct HabitItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var icon: String
    var tintHex: String
    var type: HabitType
    var frequency: HabitFrequency
    var currentValue: Int
    var targetValue: Int
    var unit: String
    var rank: String?
    var eventSummary: String?
    var hasActiveCard: Bool
    var isCompleted: Bool

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }

    var tintColor: Color {
        Color(hex: tintHex) ?? .blue
    }

    static let sampleData: [HabitItem] = [
        HabitItem(
            id: UUID(),
            title: "Lesechallenge",
            icon: "book.fill",
            tintHex: Color.blue.hexString,
            type: .measurable,
            frequency: .daily,
            currentValue: 0,
            targetValue: 20,
            unit: "Seiten",
            rank: "2",
            eventSummary: nil,
            hasActiveCard: true,
            isCompleted: false
        ),
        HabitItem(
            id: UUID(),
            title: "Workout",
            icon: "figure.strengthtraining.traditional",
            tintHex: Color.green.hexString,
            type: .binary,
            frequency: .daily,
            currentValue: 0,
            targetValue: 1,
            unit: "Session",
            rank: "1",
            eventSummary: nil,
            hasActiveCard: false,
            isCompleted: false
        ),
        HabitItem(
            id: UUID(),
            title: "Lernen",
            icon: "brain.head.profile",
            tintHex: Color.purple.hexString,
            type: .measurable,
            frequency: .daily,
            currentValue: 0,
            targetValue: 30,
            unit: "Min",
            rank: "3",
            eventSummary: nil,
            hasActiveCard: false,
            isCompleted: false
        )
    ]
}
