//
//  HabitHistoryEntry.swift
//  HabitChallenge
//
//  Created by Erik Götz on 28.06.26.
//

import Foundation

struct HabitHistoryEntry: Codable, Hashable, Identifiable {
    let id: UUID
    let periodStart: Date
    var value: Int
    var targetValue: Int
    var isCompleted: Bool
    var updatedAt: Date
}
