//
//  AddHabitView.swift
//  HabitChallenge
//
//  Created by Erik Götz on 03.06.26.
//
//  Sheet for adding new Habits to Overview. Includes Preview card

import Foundation
import SwiftUI

// MARK: - AddHabitView

struct AddHabitView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    private let habitSymbols = [
        "book.fill",
        "bookmark.fill",
        "pencil",
        "brain.head.profile",
        "laptopcomputer",
        "keyboard",
        
        "figure.walk",
        "figure.run",
        "figure.strengthtraining.traditional",
        "bicycle",
        "dumbbell.fill",
        "sportscourt.fill",
        
        "heart.fill",
        "bed.double.fill",
        "moon.fill",
        "alarm.fill",
        "drop.fill",
        "pills.fill",
        
        "fork.knife",
        "carrot.fill",
        "xmark.circle",
        "takeoutbag.and.cup.and.straw.fill",
        "waterbottle.fill",
        "leaf.fill",
        
        "person.2.fill",
        "message.fill",
        "phone.fill",
        "music.note",
        "gamecontroller.fill",
        "star.fill"
    ]
    
    @Environment(\.dismiss) private var dismiss
    @Binding var habits: [HabitItem]
    
    @State private var title = ""
    @State private var icon = ""
    @State private var targetValue: Int?
    @State private var unit = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedType: HabitType = .measurable
    @State private var selectedFrequency: HabitFrequency = .daily
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Neues Habit") {
                    TextField("Titel", text: $title)
                        .textInputAutocapitalization(.never)
                    Picker("Frequenz", selection: $selectedFrequency) {
                        ForEach(HabitFrequency.allCases) { frequency in
                            Text(frequency.title).tag(frequency)
                        }
                    }
                }
                
                Section("Habittyp") {
                    HabitTypePreviewCard(
                        title: "Mit Zielwert",
                        subtitle: "Für Gewohnheiten mit Menge, Dauer oder Anzahl.",
                        previewText: "10 Seiten / 30 min / 5 km",
                        icon: "chart.bar.fill",
                        isSelected: selectedType == .measurable,
                        tint: selectedColor,
                        action: {
                            selectedType = .measurable
                        }
                    )
                    
                    HabitTypePreviewCard(
                        title: "Einfach abhaken",
                        subtitle: "Für Gewohnheiten, die du nur als erledigt markierst.",
                        previewText: "Heute erledigt?",
                        icon: "checkmark.circle",
                        isSelected: selectedType == .binary,
                        tint: selectedColor,
                        action: {
                            selectedType = .binary
                        }
                    )
                }
                
                if selectedType == .measurable{
                    Section("Einheit & Zielwert"){

                        TextField("Einheit", text: $unit)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        TextField("Zielwert", value: $targetValue, format: .number)
                                .keyboardType(.numberPad)
                    }
                }
                
                
                Section("Symbol") {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(habitSymbols, id: \.self) { symbol in
                            Button {
                                icon = symbol
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(icon == symbol ? selectedColor.opacity(0.18) : Color(.tertiarySystemGroupedBackground))

                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(icon == symbol ? selectedColor : Color.clear, lineWidth: 1.5)

                                    Image(systemName: symbol)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(icon == symbol ? selectedColor : .primary)
                                }
                                .frame(height: 42)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Farbe") {
                    ColorPicker("Farbe", selection: $selectedColor)
                }
                Section("Vorschau") {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(selectedColor.opacity(0.15))
                                .frame(width: 42, height: 42)

                            Image(systemName: icon)
                                .foregroundStyle(selectedColor)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(title.isEmpty ? "Neues Habit" : title)
                                .font(.headline)

                            Text("0 / \(max(targetValue ?? 1, 1)) \(unit.isEmpty ? "Mal" : unit)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
            }
            .navigationTitle("Neues Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Speichern") {
                        let newHabit = HabitItem(
                            id: UUID(),
                            title: title,
                            icon: icon.isEmpty ? "star.fill" : icon,
                            tintHex: selectedColor.hexString,
                            type: selectedType,
                            frequency: selectedFrequency,
                            currentValue: 0,
                            targetValue: selectedType == .binary ? 1 : max(targetValue ?? 1, 1),
                            unit: selectedType == .binary ? "Erledigt" : (unit.isEmpty ? "Mal" : unit),
                            rank: nil,
                            eventSummary: nil,
                            hasActiveCard: false,
                            isCompleted: false
                        )

                        habits.append(newHabit)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - HabitTypePreviewCard

struct HabitTypePreviewCard: View {
    let title: String
    let subtitle: String
    let previewText: String
    let icon: String
    let isSelected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(tint)

                    Text(title)
                        .font(.headline)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(tint)
                    }
                }

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(previewText)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? tint : Color.clear, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

