//
//  HabitChallenge
//  Main function with the main views and logics
//
//  Created by Erik Götz on 11.05.26.
//
//  MARK: - TodayView

import SwiftUI

struct MainView: View {
    @StateObject private var store = HabitStore()
    @State private var showingAddHabitSheet = false
    @State private var navigationPath = NavigationPath()
    @Environment(\.scenePhase) private var scenePhase

    private var dailyHabits: [HabitItem] {
        store.habits.filter { $0.frequency == .daily }
    }

    private var weeklyHabits: [HabitItem] {
        store.habits.filter { $0.frequency == .weekly }
    }

    private var completedDailyCount: Int {
        dailyHabits.filter(\.isCompleted).count
    }

    private var completedWeeklyCount: Int {
        weeklyHabits.filter(\.isCompleted).count
    }

    private var newEventsCount: Int {
        store.habits.filter { $0.eventSummary != nil }.count
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    HabitSummary(
                        completedDailyCount: completedDailyCount,
                        totalDailyCount: dailyHabits.count,
                        completedWeeklyCount: completedWeeklyCount,
                        totalWeeklyCount: weeklyHabits.count,
                        newEventsCount: newEventsCount
                    )
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if newEventsCount > 0 {
                    Section {
                        ChallengeEventBanner(
                            text: "Heute gibt es neue Challenge-Ereignisse in deinen Habits."
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }

                HabitListSection(
                    title: "Daily Habits",
                    habits: dailyHabits,
                    navigationPath: $navigationPath
                )
                .environmentObject(store)

                HabitListSection(
                    title: "Weekly Habits",
                    habits: weeklyHabits,
                    navigationPath: $navigationPath
                )
                .environmentObject(store)   
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Habit-Übersicht")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddHabitSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabitSheet) {
                AddHabitView()
                    .environmentObject(store)
            }
            .navigationDestination(for: UUID.self) { habitID in
                HabitDetailView(habitID: habitID)
                    .environmentObject(store)
            }
            .onAppear {
                store.resetHabitsIfNeeded()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    store.resetHabitsIfNeeded()
                }
            }
        }
    }
}

struct HabitSummary: View {
    let completedDailyCount: Int
    let totalDailyCount: Int
    let completedWeeklyCount: Int
    let totalWeeklyCount: Int
    let newEventsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                SummaryChip(
                    title: "Heute",
                    value: "\(completedDailyCount)/\(totalDailyCount)",
                    color: .gray
                )

                SummaryChip(
                    title: "Woche",
                    value: "\(completedWeeklyCount)/\(totalWeeklyCount)",
                    color: .gray
                )

                SummaryChip(
                    title: "Events",
                    value: "\(newEventsCount)",
                    color: .gray
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Components

struct SummaryChip: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.primary)

            Text(value)
                .font(.title2)
                .foregroundStyle(.primary)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.50))
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
        .background(Color.orange.opacity(0.50))
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
                        .fill(habit.tintColor.opacity(0.15))
                        .frame(width: 42, height: 42)

                    Image(systemName: habit.icon)
                        .foregroundStyle(habit.tintColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.title3)
                        .bold()

                    Text("\(habit.currentValue) / \(habit.targetValue) \(habit.unit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 6)
            }

            ProgressView(value: habit.progress)
                .tint(habit.tintColor)

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

// MARK: - HabitListSection

struct HabitListSection: View {
    @EnvironmentObject private var store: HabitStore

    let title: String
    let habits: [HabitItem]
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Section(title) {
            if habits.isEmpty {
                EmptyHabitCard(
                    title: "Noch keine Habits",
                    subtitle: title == "Daily Habits"
                    ? "Lege ein tägliches Habit an, um hier zu starten."
                    : "Lege ein wöchentliches Habit an, um hier zu starten."
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(habits) { habit in
                    Button {
                        navigationPath.append(habit.id)
                    } label: {
                        HabitCardView(habit: habit)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            store.deleteHabit(habit)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - EmptyHabitCard

struct EmptyHabitCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.12))
                        .frame(width: 42, height: 42)

                    Image(systemName: "plus.circle")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .bold()

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 4)
    }
}

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}

