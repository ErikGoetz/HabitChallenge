//
//  EditHabitView.swift
//  HabitChallenge
//
//  Created by Erik Götz on 03.06.26.
//
//  struct for editing Habits in detailview

import SwiftUI

// MARK: - EditHabitView

struct EditHabitView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    private let habitSymbols = [
        "book.fill", "bookmark.fill", "pencil", "brain.head.profile", "laptopcomputer", "keyboard",
        "figure.walk", "figure.run", "figure.strengthtraining.traditional", "bicycle", "dumbbell.fill", "sportscourt.fill",
        "heart.fill", "bed.double.fill", "moon.fill", "alarm.fill", "drop.fill", "pills.fill",
        "fork.knife", "carrot.fill", "xmark.circle", "takeoutbag.and.cup.and.straw.fill", "waterbottle.fill", "leaf.fill",
        "person.2.fill", "message.fill", "phone.fill", "music.note", "gamecontroller.fill", "star.fill"
    ]

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: HabitStore

    let habit: HabitItem

    @State private var title: String
    @State private var icon: String
    @State private var targetValue: Int?
    @State private var unit: String
    @State private var selectedColor: Color
    @State private var selectedType: HabitType
    @State private var selectedFrequency: HabitFrequency

    init(habit: HabitItem) {
        self.habit = habit
        _title = State(initialValue: habit.title)
        _icon = State(initialValue: habit.icon)
        _targetValue = State(initialValue: habit.targetValue)
        _unit = State(initialValue: habit.unit)
        _selectedColor = State(initialValue: habit.tintColor)
        _selectedType = State(initialValue: habit.type)
        _selectedFrequency = State(initialValue: habit.frequency)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit bearbeiten") {
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
                        tint: selectedColor
                    ) {
                        selectedType = .measurable
                    }

                    HabitTypePreviewCard(
                        title: "Einfach abhaken",
                        subtitle: "Für Gewohnheiten, die du nur als erledigt markierst.",
                        previewText: "Heute erledigt?",
                        icon: "checkmark.circle",
                        isSelected: selectedType == .binary,
                        tint: selectedColor
                    ) {
                        selectedType = .binary
                    }
                }

                if selectedType == .measurable {
                    Section("Einheit & Zielwert") {
                        TextField("Zielwert", value: $targetValue, format: .number)
                            .keyboardType(.numberPad)

                        TextField("Einheit", text: $unit)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
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
                                        .stroke(icon == symbol ? selectedColor : .clear, lineWidth: 1.5)

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
            }
            .navigationTitle("Habit bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Speichern") {
                        var updatedHabit = habit
                        updatedHabit.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        updatedHabit.icon = icon.isEmpty ? "star.fill" : icon
                        updatedHabit.tintHex = selectedColor.hexString
                        updatedHabit.type = selectedType
                        updatedHabit.frequency = selectedFrequency

                        if selectedType == .binary {
                            updatedHabit.targetValue = 1
                            updatedHabit.unit = "Erledigt"
                            updatedHabit.currentValue = updatedHabit.isCompleted ? 1 : 0
                        } else {
                            updatedHabit.targetValue = max(targetValue ?? 1, 1)
                            updatedHabit.unit = unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Mal" : unit
                            updatedHabit.isCompleted = updatedHabit.currentValue >= updatedHabit.targetValue
                        }

                        store.updateHabit(updatedHabit)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
