//
//  HabitType.swift
//  HabitChallenge
//
//  Created by Erik Götz on 03.06.26.
//
//  Enum for the two HabitTypes: "With target value" or "just got done"


import Foundation

enum HabitType: String, CaseIterable, Identifiable, Codable {
    case binary
    case measurable

    var id: Self { self }

    var title: String {
        switch self {
        case .binary:
            return "erledigt/nicht erledigt"
        case .measurable:
            return "Zahlenwert"
        }
    }
}
