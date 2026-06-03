//
//  HabitFrequency.swift
//  HabitChallenge
//
//  Created by Erik Götz on 03.06.26.
//
//  Enum for the different frequency types for a habit. Currently daily and weekly

import Foundation

enum HabitFrequency: String, CaseIterable, Identifiable, Codable {
    case daily
    case weekly

    var id: Self { self }

    var title: String {
        switch self {
        case .daily:
            return "Täglich"
        case .weekly:
            return "Wöchentlich"
        }
    }
}
