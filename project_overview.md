# HabitChallenge – Projektzusammenfassung

_Zuletzt aktualisiert: 04.06.2026_

---

## Zweck des Dokuments

Dieses Dokument bündelt den aktuellen Wissensstand zur SwiftUI-App **HabitChallenge**. Es dient als lebendes Projektdokument, das nach jedem Meilenstein aktualisiert wird. Architektur, offene Themen, umgesetzte Entscheidungen und nächste Schritte werden hier zentral festgehalten.

---

## Projektziel

HabitChallenge ist eine SwiftUI-App zur Verwaltung von täglichen und wöchentlichen Habits. Die App soll Habits anlegen, anzeigen, im Detail bearbeiten und abhängig vom Habittyp unterschiedlich behandeln: entweder als messbares Habit mit Zielwert oder als binäres Habit (erledigt / nicht erledigt).

Mittelfristig soll sich die App zu einer vollständigen **Habit-Zentrale mit Challenge-Funktionalität** entwickeln – inklusive Fortschritts-Tracking, Streaks und sozialen oder persönlichen Challenges.

---

## Was die App bereits kann

- **Hauptscreen (`MainView`):** Übersicht über Daily- und Weekly-Habits, zusammenfassende Kennzahlen (erledigte Habits, neue Events), `ChallengeEventBanner`
- **Habittypen:** `binary` (erledigt/nicht erledigt) und `measurable` (numerischer Fortschritt mit Zielwert)
- **Habitfrequenzen:** `täglich` und `wöchentlich`
- **Detailansicht (`HabitDetailView`):** Typ-spezifische Darstellung via `BinaryHabitCard` und `MeasurableHabitCard`, Fortschrittsanzeige, Quick-Add-Buttons, `HabitHeroCard`, `RankCard`
- **Habit anlegen (`AddHabitView`):** Sheet mit Typauswahl, Icon, Farbe, Zielwert, Frequenz
- **Habit bearbeiten (`EditHabitView`):** Edit-Button oben rechts in der Detailansicht, eigenes Sheet
- **Persistenz:** `HabitStore` mit `UserDefaults`, `@Published`-State, automatisches Laden beim Start
- **Navigation:** `NavigationStack`, UUID-basierte Navigation zur Detailansicht
- **Dateistruktur:** Aufgeteilt in `Models/`, `Stores/`, `Views/`, `Extensions/`

---

## Habittypen

| Typ | Verhalten | `currentValue` | `isCompleted` |
|---|---|---|---|
| `binary` | Nur abhaken | Wird über `isCompleted` synchronisiert | Direkt gesetzt |
| `measurable` | Zahleneingabe + Ziel | Numerischer Fortschritt | `currentValue >= targetValue` |

---

## Datenmodell (`HabitItem`)

Zentrale Felder: `title`, `icon`, `tintHex`, `type` (`HabitType`), `frequency` (`HabitFrequency`), `currentValue`, `targetValue`, `unit`, `rank`, `eventSummary`, `hasActiveCard`, `isCompleted`.

---

## Dateistruktur (aktuell)

```text
HabitChallenge/
├── Models/
│   ├── HabitItem.swift
│   ├── HabitType.swift
│   └── HabitFrequency.swift
│
├── Stores/
│   └── HabitStore.swift
│
├── Views/
│   ├── Main/
│   │   └── MainView.swift
│   ├── HabitDetail/
│   │   └── HabitDetailView.swift
│   └── HabitForm/
│       └── AddHabitView.swift
│
└── Extensions/
    └── Color+Hex.swift
```

---

## Umgesetzte UX-Entscheidungen

- Detailansicht ist der bevorzugte Ort für die Bearbeitung eines Habits
- Edit-Button oben rechts in der Detailansicht öffnet `EditHabitView`
- Binäre Habits zeigen keine Zahleneingabe, nur Status + Toggle
- Messbare Habits behalten Fortschrittsanzeige, Zielwert und Quick-Add

---

## Offene Bugs

| Bug | Status |
|---|---|
| Dark-Mode-Sheet-Bug: weißer/heller Streifen oben beim Öffnen von `AddHabitView` | Noch offen – `Form`, Safe-Area und NavigationStack als mögliche Ursachen identifiziert |

---

## Nächste Schritte (priorisiert)

> **Schritte 1 und 2 sind erledigt** (Refaktorierung + EditHabitView).

### ✅ Schritt 1 – Zwischen-Refaktorierung (ERLEDIGT)
Models, Store, Views und Extensions in eigene Dateien getrennt.

### ✅ Schritt 2 – Habit-Bearbeitung (ERLEDIGT)
`EditHabitView` mit Edit-Button in der Detailansicht umgesetzt.

### ✅ Schritt 3 – Automatischer Habit-Reset (NEU)
`currentValue` muss frequenzabhängig automatisch zurückgesetzt werden:
- **Daily-Habits** werden täglich um Mitternacht zurückgesetzt
- **Weekly-Habits** werden wöchentlich (z. B. montags) zurückgesetzt
- Implementierung: Beim App-Start prüfen, ob seit dem letzten Reset ein neuer Tag/eine neue Woche begonnen hat
- Felder im Modell ergänzen: `lastResetDate: Date`
- Reset-Logik in `HabitStore`, z. B. `func resetIfNeeded()`

### Schritt 4 – Habit-Tracking & Streaks (NEU)
Tracking des Fortschritts über die Zeit, um Motivation und Rückmeldung zu verbessern:
- **Streak-Anzeige:** Letzten 7 Tage (Daily) bzw. 7 Wochen (Weekly) als visuelle Übersicht (z. B. kleine Kreise/Kästchen, gefüllt = erledigt)
- **Completion-Quote:** Prozentualer Anteil, wie oft ein Habit im gewählten Zeitraum abgeschlossen wurde (z. B. „5/7 – 71 %")
- **Datenmodell-Erweiterung:** `completionLog: [Date]` – ein Array der Daten, an denen das Habit abgeschlossen wurde
- Beim erfolgreichen Abschließen eines Habits wird das aktuelle Datum in `completionLog` eingetragen
- Neuer UI-Baustein in der Detailansicht: `HabitStreakView` oder `HabitHistoryCard`

### Schritt 5 – Challenge-Funktionen (NEU)
Einführung eines Challenge-Systems als Kernfeature der App:
- **Persönliche Challenge:** Ein Habit für einen definierten Zeitraum als Challenge markieren (z. B. „30 Tage kein Alkohol") mit Start- und Enddatum
- **Challenge-Fortschritt:** Dedizierte Challenge-Ansicht mit Countdown, Fortschrittsbalken und Streak
- **Challenge-Status:** Aktiv, abgeschlossen (erfolgreich), abgebrochen
- **Challenge-Archiv:** Vergangene Challenges einsehen, inkl. Erfolgsquote
- Mögliche spätere Erweiterung: Challenges mit anderen teilen oder gegeneinander antreten (soziale Komponente)

---

## Empfohlene Grundfunktionen vor den Challenge-Features

Bevor Challenges vollständig eingeführt werden, sollten diese Grundlagen solide stehen:

| Feature | Grund |
|---|---|
| Completion-Log / Tracking (Schritt 4) | Challenge-Fortschritt baut direkt darauf auf |
| Habit-Sortierung / Reihenfolge ändern | Bessere UX im Hauptscreen bei wachsender Habit-Anzahl |
| Habit archivieren / pausieren | Verhindert, dass abgeschlossene Challenges den Hauptscreen überladen |
| Notifications (optional) | Erinnerungen pro Habit steigern die Nutzungsrate erheblich |

---

## Technische Risiken

| Risiko | Beschreibung |
|---|---|
| UI-Komplexität | Wachsende Datenmenge erfordert klare Trennung von View-Logik und Store-Logik |
| Form/NavigationStack im Sheet | Sheet/Form-Verhalten schwer kontrollierbar |
| Datenmigration | Neue Modellfelder (`lastResetDate`, `completionLog`) müssen rückwärtskompatibel ergänzt werden |

---

## Späteres Backlog

- Gemeinsame Formularbausteine für `AddHabitView` und `EditHabitView` extrahieren
- `Form` in Sheets ggf. durch `ScrollView`-basierte Lösung ersetzen
- Widget-Unterstützung (WidgetKit) für Habit-Status auf dem Homescreen
- iCloud-Sync über CloudKit
- Soziale Challenge-Funktionen (Freunde einladen, gemeinsame Challenges)
