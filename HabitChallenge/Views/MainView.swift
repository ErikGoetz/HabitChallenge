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

    private var dailyHabitIndices: [Int] {
        store.habits.indices.filter { store.habits[$0].frequency == .daily }
    }

    private var weeklyHabitIndices: [Int] {
        store.habits.indices.filter { store.habits[$0].frequency == .weekly }
    }

    private var completedDailyCount: Int {
        dailyHabitIndices.filter { store.habits[$0].isCompleted }.count
    }

    private var completedWeeklyCount: Int {
        weeklyHabitIndices.filter { store.habits[$0].isCompleted }.count
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
                        totalDailyCount: dailyHabitIndices.count,
                        completedWeeklyCount: completedWeeklyCount,
                        totalWeeklyCount: weeklyHabitIndices.count,
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
                    indices: dailyHabitIndices,
                    habits: $store.habits,
                    navigationPath: $navigationPath
                )

                HabitListSection(
                    title: "Weekly Habits",
                    indices: weeklyHabitIndices,
                    habits: $store.habits,
                    navigationPath: $navigationPath
                )
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
                AddHabitView(habits: $store.habits)
            }
            .navigationDestination(for: UUID.self) { habitID in
                if let index = store.habits.firstIndex(where: { $0.id == habitID }) {
                    HabitDetailView(habit: $store.habits[index])
                } else {
                    Text("Habit nicht gefunden")
                }
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


// MARK: - Components

struct HabitSummary: View {
    let completedDailyCount: Int
    let totalDailyCount: Int
    let completedWeeklyCount: Int
    let totalWeeklyCount: Int
    let newEventsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            //Text("Übersicht")
                //.font(.headline)

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

// MARK: - HabitCardView

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
                    HStack {
                        Text(habit.title)
                            .font(.title3)
                            .bold()

                        /*if habit.hasActiveCard {
                            Text("Karte aktiv")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.14))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }*/
                    }
                    //HStack{
                        //Image(systemName: "trophy.fill")
                            .font(.subheadline)
                        
                        //if let rank = habit.rank {
                            //Text("\(rank). Platz")
                                .font(.headline)
                        //}
                            
                        
                    //}
                    
                    //Spacer()
                        
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
    let title: String
    let indices: [Int]
    @Binding var habits: [HabitItem]
    @Binding var navigationPath: NavigationPath

    private func deleteHabit(at index: Int) {
        guard habits.indices.contains(index) else { return }
        habits.remove(at: index)
    }

    var body: some View {
        Section(title) {
            if indices.isEmpty {
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
                ForEach(indices, id: \.self) { index in
                    Button {
                        navigationPath.append(habits[index].id)
                    } label: {
                        HabitCardView(habit: habits[index])
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteHabit(at: index)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.primary)
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

