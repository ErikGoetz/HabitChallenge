//
//  ContentView.swift
//  HabitChallenge
//
//  Created by Erik Götz on 11.05.26.
//

import SwiftUI

struct TodayView: View {
    @State private var habits: [HabitItem] = HabitItem.sampleData

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        TodaySummaryCard(
                            completedCount: habits.filter(\.isCompleted).count,
                            totalCount: habits.count,
                            newEventsCount: habits.filter { $0.eventSummary != nil }.count
                        )
                        .padding(.horizontal)

                        if habits.contains(where: { $0.eventSummary != nil }) {
                            ChallengeEventBanner(
                                text: "Heute gibt es neue Challenge-Ereignisse in deinen Habits."
                            )
                            .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Deine Habits")
                                .font(.title2.bold())
                                .padding(.horizontal)

                            ForEach(habits) { habit in
                                NavigationLink {
                                    HabitDetailView(habit: habit)
                                } label: {
                                    HabitCardView(habit: habit)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Heute")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // später: neues Habit anlegen
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: - Model

struct HabitItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let tint: Color
    let currentValue: Int
    let targetValue: Int
    let unit: String
    let challengeSummary: String?
    let eventSummary: String?
    let hasActiveCard: Bool
    let isCompleted: Bool

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }

    static let sampleData: [HabitItem] = [
        HabitItem(
            title: "Lesen",
            icon: "book.fill",
            tint: .blue,
            currentValue: 6,
            targetValue: 20,
            unit: "Seiten",
            challengeSummary: "Lesechallenge · Platz 2",
            eventSummary: "Intensivtag aktiv: heute 20 statt 10 Seiten",
            hasActiveCard: true,
            isCompleted: false
        ),
        HabitItem(
            title: "Workout",
            icon: "figure.strengthtraining.traditional",
            tint: .green,
            currentValue: 1,
            targetValue: 1,
            unit: "Session",
            challengeSummary: "Workout Crew · Platz 1",
            eventSummary: nil,
            hasActiveCard: false,
            isCompleted: true
        ),
        HabitItem(
            title: "Lernen",
            icon: "brain.head.profile",
            tint: .purple,
            currentValue: 25,
            targetValue: 30,
            unit: "Min",
            challengeSummary: nil,
            eventSummary: "Neue Karte gespielt in deiner Fokusgruppe",
            hasActiveCard: false,
            isCompleted: false
        )
    ]
}

// MARK: - Components

struct TodaySummaryCard: View {
    let completedCount: Int
    let totalCount: Int
    let newEventsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tagesübersicht")
                .font(.headline)

            HStack(spacing: 12) {
                SummaryChip(
                    title: "Erledigt",
                    value: "\(completedCount)/\(totalCount)",
                    color: .blue
                )

                SummaryChip(
                    title: "Events",
                    value: "\(newEventsCount)",
                    color: .orange
                )
            }

            Text("Tippe auf ein Habit, um Rang, Gruppe und gespielte Karten zu sehen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct SummaryChip: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ChallengeEventBanner: View {
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(.orange)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct HabitCardView: View {
    let habit: HabitItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(habit.tint.opacity(0.15))
                        .frame(width: 42, height: 42)

                    Image(systemName: habit.icon)
                        .foregroundStyle(habit.tint)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(habit.title)
                            .font(.headline)

                        if habit.hasActiveCard {
                            Text("Karte aktiv")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.14))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }

                    Text("\(habit.currentValue) / \(habit.targetValue) \(habit.unit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let challengeSummary = habit.challengeSummary {
                        Text(challengeSummary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 6)
            }

            ProgressView(value: habit.progress)
                .tint(habit.tint)

            if let eventSummary = habit.eventSummary {
                Label(eventSummary, systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.top, 2)
            }

            if habit.isCompleted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    Text("Heute bereits erledigt")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.green)
                }
                .padding(.top, 2)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Placeholder Detail View

struct HabitDetailView: View {
    let habit: HabitItem

    @State private var enteredValue: Int
    @State private var isCompleted: Bool

    init(habit: HabitItem) {
        self.habit = habit
        _enteredValue = State(initialValue: habit.currentValue)
        _isCompleted = State(initialValue: habit.isCompleted)
    }

    var progress: Double {
        guard habit.targetValue > 0 else { return 0 }
        return min(Double(enteredValue) / Double(habit.targetValue), 1.0)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HabitHeroCard(
                        title: habit.title,
                        icon: habit.icon,
                        tint: habit.tint,
                        challengeSummary: habit.challengeSummary,
                        eventSummary: habit.eventSummary,
                        isCompleted: isCompleted
                    )

                    ProgressSectionCard(
                        enteredValue: enteredValue,
                        targetValue: habit.targetValue,
                        unit: habit.unit,
                        progress: progress,
                        tint: habit.tint
                    )

                    InputSectionCard(
                        value: $enteredValue,
                        targetValue: habit.targetValue,
                        unit: habit.unit
                    )

                    ActionSectionCard(
                        isCompleted: $isCompleted,
                        tint: habit.tint
                    )
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hero

struct HabitHeroCard: View {
    let title: String
    let icon: String
    let tint: Color
    let challengeSummary: String?
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

                    if let challengeSummary {
                        Text(challengeSummary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            if let eventSummary {
                Label(eventSummary, systemImage: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
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

// MARK: - Progress

struct ProgressSectionCard: View {
    let enteredValue: Int
    let targetValue: Int
    let unit: String
    let progress: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Heutiger Fortschritt")
                .font(.headline)

            HStack(alignment: .lastTextBaseline) {
                Text("\(enteredValue)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("/ \(targetValue) \(unit)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            ProgressView(value: progress)
                .tint(tint)

            Text(progress >= 1 ? "Tagesziel erreicht." : "Noch \(max(targetValue - enteredValue, 0)) \(unit) bis zum Ziel.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - Input

struct InputSectionCard: View {
    @Binding var value: Int
    let targetValue: Int
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Eintragen")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Heute geschafft")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    TextField("0", value: $value, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: $value, in: 0...max(targetValue * 3, 10), step: 1) {
                Text("Wert anpassen: \(value) \(unit)")
                    .font(.subheadline)
            }

            HStack(spacing: 10) {
                QuickAddButton(title: "+1") {
                    value += 1
                }

                QuickAddButton(title: "+5") {
                    value += 5
                }

                QuickAddButton(title: "Ziel") {
                    value = targetValue
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

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

// MARK: - Actions

struct ActionSectionCard: View {
    @Binding var isCompleted: Bool
    let tint: Color

    var body: some View {
        VStack(spacing: 12) {
            Button {
                // später: Wert speichern
            } label: {
                Text("Fortschritt speichern")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(tint)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Button {
                isCompleted.toggle()
            } label: {
                Text(isCompleted ? "Erledigt-Markierung entfernen" : "Als erledigt markieren")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.tertiarySystemGroupedBackground))
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

#Preview {
    TodayView()
}
