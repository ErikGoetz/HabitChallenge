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
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    if newEventsCount > 0 {
                        ChallengeEventBanner(
                            text: "Heute gibt es neue Challenge-Ereignisse in deinen Habits."
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
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
        }
    }
}

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

// MARK: - Habit Detail View

struct HabitDetailView: View {
    @Binding var habit: HabitItem

    var progress: Double {
        guard habit.targetValue > 0 else { return 0 }
        return min(Double(habit.currentValue) / Double(habit.targetValue), 1.0)
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
                            value: $habit.currentValue,
                            targetValue: habit.targetValue,
                            unit: habit.unit,
                            tint: habit.tintColor
                        )
                    } else {
                        BinaryHabitCard(
                            isCompleted: $habit.isCompleted,
                            currentValue: $habit.currentValue,
                            tint: habit.tintColor
                        )
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: habit.currentValue) { _, newValue in
            if habit.currentValue < 0 {
                habit.currentValue = 0
            }

            if habit.type == .measurable {
                habit.isCompleted = habit.currentValue >= habit.targetValue
            }
        }
        .onChange(of: habit.isCompleted) { _, newValue in
            if habit.type == .binary {
                habit.currentValue = newValue ? 1 : 0
            }
        }
    }
}

// MARK: - Hero Card

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

                    //if let rank {
                        //Text(rank)
                            //.font(.headline)
                            //.foregroundStyle(.secondary)
                    //}
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
// MARK: - Rank Card

struct RankCard: View {
    let rank: String?
    let points: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack{
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
                    value: "\(String(points))",
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
    @Binding var value: Int
    let targetValue: Int
    let unit: String
    let tint: Color

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
                TextField("0", value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                QuickAddButton(title: "0") { value = 0 }
                QuickAddButton(title: "+1") { value += 1 }
                QuickAddButton(title: "+5") { value += 5 }
                QuickAddButton(title: "Ziel") { value = targetValue }
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

// MARK: - BinaryHabitCard

struct BinaryHabitCard: View {
    @Binding var isCompleted: Bool
    @Binding var currentValue: Int
    let tint: Color

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

            Button {
                isCompleted.toggle()
                currentValue = isCompleted ? 1 : 0
            } label: {
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

