//
//  HabitDetailView.swift
//  HabitChallenge
//
//  Created by Erik Götz on 03.06.26.
//
//  Includes all details of the habits and appears when user clicks on detail

import Foundation
import SwiftUI

// MARK: - HabitDetailView

struct HabitDetailView: View {
    @EnvironmentObject private var store: HabitStore

    let habitID: UUID
    @State private var showingEditSheet = false
    @State private var measurableInput = ""

    private var habit: HabitItem? {
        store.habit(withID: habitID)
    }

    var body: some View {
        Group {
            if let habit {
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HabitHeroCard(
                                title: habit.title,
                                icon: habit.icon,
                                tint: habit.tintColor,
                                frequency: habit.frequency,
                                type: habit.type,
                                rank: habit.rank,
                                eventSummary: habit.eventSummary,
                                isCompleted: habit.isCompleted
                            )

                            RankCard(
                                rank: habit.rank,
                                points: 400,
                                tint: habit.tintColor
                            )

                            if habit.type == .measurable {
                                MeasurableHabitCard(
                                    value: habit.currentValue,
                                    targetValue: habit.targetValue,
                                    unit: habit.unit,
                                    tint: habit.tintColor,
                                    inputValue: $measurableInput,
                                    onSetValue: { newValue in
                                        store.updateMeasurableProgress(for: habit.id, to: newValue)
                                    }
                                )
                            } else {
                                BinaryHabitCard(
                                    isCompleted: habit.isCompleted,
                                    tint: habit.tintColor,
                                    onToggle: {
                                        store.toggleBinaryHabit(habit.id)
                                    }
                                )
                            }
                        }
                        .padding()
                        .padding(.bottom, 24)
                    }
                }
                .navigationTitle(habit.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    EditHabitView(habit: habit)
                        .environmentObject(store)
                }
                .onAppear {
                    measurableInput = "\(habit.currentValue)"
                }
                .onChange(of: habit.currentValue) { _, newValue in
                    measurableInput = "\(newValue)"
                }
            } else {
                Text("Habit nicht gefunden")
            }
        }
    }
}

// MARK: - HabitHeroCard

struct HabitHeroCard: View {
    let title: String
    let icon: String
    let tint: Color
    let frequency: HabitFrequency
    let type: HabitType
    let rank: String?
    let eventSummary: String?
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.16))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())

                    Text("\(frequency.title) · \(type == .binary ? "Einfach abhaken" : "Mit Zielwert")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if let eventSummary {
                Label {
                    Text(eventSummary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } icon: {
                    Image(systemName: "sparkles")
                }
                .font(.headline)
                .foregroundStyle(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            if isCompleted {
                Label("Heute bereits erledigt", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - RankCard

struct RankCard: View {
    let rank: String?
    let points: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                    .font(.title2)

                Text("Platzierung")
                    .font(.title2)
                    .bold()
            }

            HStack(spacing: 12) {
                SummaryChip(
                    title: "Rang",
                    value: rank ?? "-",
                    color: tint
                )

                SummaryChip(
                    title: "Punkte",
                    value: "\(points)",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - MeasurableHabitCard

struct MeasurableHabitCard: View {
    let value: Int
    let targetValue: Int
    let unit: String
    let tint: Color
    @Binding var inputValue: String
    let onSetValue: (Int) -> Void

    private var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(value) / Double(targetValue), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fortschritt")
                .font(.title2)
                .bold()

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(value)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("/ \(targetValue) \(unit)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            ProgressView(value: progress)
                .tint(tint)

            Text(progress >= 1 ? "Ziel erreicht." : "Noch \(max(targetValue - value, 0)) \(unit) bis zum Ziel.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                TextField("0", text: $inputValue)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        onSetValue(Int(inputValue) ?? 0)
                    }

                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                QuickAddButton(title: "0") { onSetValue(0) }
                QuickAddButton(title: "+1") { onSetValue(value + 1) }
                QuickAddButton(title: "+5") { onSetValue(value + 5) }
                QuickAddButton(title: "Ziel") { onSetValue(targetValue) }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - BinaryHabitCard

struct BinaryHabitCard: View {
    let isCompleted: Bool
    let tint: Color
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.title2)
                .bold()

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill((isCompleted ? Color.green : Color.red).opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isCompleted ? .green : Color.red)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isCompleted ? "Bereits erledigt" : "Noch offen")
                        .font(.headline)

                    Text("Für diesen Zeitraum einfach abhaken.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Button(action: onToggle) {
                Text(isCompleted ? "Als nicht erledigt markieren" : "Als erledigt markieren")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(tint.opacity(0.14))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - QuickAddButton

struct QuickAddButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
