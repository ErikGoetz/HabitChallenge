//
//  HabitChallenge
//
//  Created by Erik Götz on 11.05.26.
//
//  MARK: - TodayView

import SwiftUI

struct TodayView: View {
    @State private var habits: [HabitItem] = HabitItem.sampleData
    @State private var showingAddHabitSheet = false

    private var dailyHabitIndices: [Int] {
        habits.indices.filter { habits[$0].frequency == .daily }
    }

    private var weeklyHabitIndices: [Int] {
        habits.indices.filter { habits[$0].frequency == .weekly }
    }

    private var completedDailyCount: Int {
        dailyHabitIndices.filter { habits[$0].isCompleted }.count
    }

    private var completedWeeklyCount: Int {
        weeklyHabitIndices.filter { habits[$0].isCompleted }.count
    }

    private var newEventsCount: Int {
        habits.filter { $0.eventSummary != nil }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        TodaySummaryCard(
                            completedDailyCount: completedDailyCount,
                            totalDailyCount: dailyHabitIndices.count,
                            completedWeeklyCount: completedWeeklyCount,
                            totalWeeklyCount: weeklyHabitIndices.count,
                            newEventsCount: newEventsCount
                        )
                        .padding(.horizontal)

                        if newEventsCount > 0 {
                            ChallengeEventBanner(
                                text: "Heute gibt es neue Challenge-Ereignisse in deinen Habits."
                            )
                            .padding(.horizontal)
                        }

                        HabitSection(
                            title: "Daily Habits",
                            indices: dailyHabitIndices,
                            habits: $habits
                        )

                        HabitSection(
                            title: "Weekly Habits",
                            indices: weeklyHabitIndices,
                            habits: $habits
                        )
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
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
                AddHabitView(habits: $habits)
            }
        }
    }
}

// MARK: - ENUMs

enum HabitType: String, CaseIterable, Identifiable {
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

enum HabitFrequency: String, CaseIterable, Identifiable {
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

// MARK: - Model

struct HabitItem: Identifiable, Hashable {
    let id: UUID = UUID()
        var title: String
        var icon: String
        var tint: Color
        var type: HabitType
        var frequency: HabitFrequency
        var currentValue: Int
        var targetValue: Int
        var unit: String
        var rank: String?
        var eventSummary: String?
        var hasActiveCard: Bool
        var isCompleted: Bool

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }

    static let sampleData: [HabitItem] = [
        HabitItem(
            title: "Lesechallenge",
            icon: "book.fill",
            tint: .blue,
            type: .measurable,
            frequency: .daily,
            currentValue: 0,
            targetValue: 20,
            unit: "Seiten",
            rank: "2",
            eventSummary: nil,
            hasActiveCard: true,
            isCompleted: false
        ),
        HabitItem(
            title: "Workout",
            icon: "figure.strengthtraining.traditional",
            tint: .green,
            type: .binary,
            frequency: .daily,
            currentValue: 0,
            targetValue: 1,
            unit: "Session",
            rank: "1",
            eventSummary: nil,
            hasActiveCard: false,
            isCompleted: false
        ),
        HabitItem(
            title: "Lernen",
            icon: "brain.head.profile",
            tint: .purple,
            type: .measurable,
            frequency: .daily,
            currentValue: 0,
            targetValue: 30,
            unit: "Min",
            rank: "3",
            eventSummary: nil,
            hasActiveCard: false,
            isCompleted: false
        )
    ]
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
                
                Section("Habittyp verstehen") {
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
                            title: title,
                            icon: icon.isEmpty ? "star.fill" : icon,
                            tint: selectedColor,
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

// MARK: - HabitSection

struct HabitSection: View {
    let title: String
    let indices: [Int]
    @Binding var habits: [HabitItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal)
                .foregroundStyle(.primary)

            if indices.isEmpty {
                Text("Noch keine Habits in diesem Bereich.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(indices, id: \.self) { index in
                    NavigationLink {
                        HabitDetailView(habit: $habits[index])
                    } label: {
                        HabitCardView(habit: habits[index])
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Components

struct TodaySummaryCard: View {
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
                        .fill(habit.tint.opacity(0.15))
                        .frame(width: 42, height: 42)

                    Image(systemName: habit.icon)
                        .foregroundStyle(habit.tint)
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
                        tint: habit.tint,
                        rank: habit.rank,
                        eventSummary: habit.eventSummary,
                        isCompleted: habit.isCompleted
                    )

                    RankCard(
                        rank: habit.rank,
                        points: 400,
                        tint: habit.tint
                    )

                    ProgressSectionCard(
                        enteredValue: habit.currentValue,
                        targetValue: habit.targetValue,
                        unit: habit.unit,
                        progress: progress,
                        tint: habit.tint
                    )

                    InputSectionCard(
                        value: $habit.currentValue,
                        targetValue: habit.targetValue,
                        unit: habit.unit
                    )

                    ActionSectionCard(
                        isCompleted: $habit.isCompleted,
                        tint: habit.tint
                    )
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: habit.currentValue) { _, newValue in
            if newValue >= habit.targetValue && !habit.isCompleted{
                habit.isCompleted = true
            }
        }
    }
}

// MARK: - Hero Card

struct HabitHeroCard: View {
    let title: String
    let icon: String
    let tint: Color
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


// MARK: - Progress Card

struct ProgressSectionCard: View {
    let enteredValue: Int
    let targetValue: Int
    let unit: String
    let progress: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Heutiger Fortschritt")
                .font(.title2)
                .bold()

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

// MARK: - Input Card

struct InputSectionCard: View {
    @Binding var value: Int
    let targetValue: Int
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Eintragen")
                .font(.title2)
                .bold()

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
/*
            Stepper(value: $value, in: 0...max(targetValue * 3, 10), step: 1) {
                Text("Wert anpassen: \(value) \(unit)")
                    .font(.subheadline)

            }*/

            HStack(spacing: 10) {
                QuickAddButton(title: "0") {
                    value = 0
                }
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
        .preferredColorScheme(.dark)
}

