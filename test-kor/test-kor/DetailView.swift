//
//  DetailView.swift
//  test-kor
//
//  Created by Jakub Korcz on 25/03/2026.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    // @Bindable pozwala na bezpośrednie połączenie pól formularza z modelem SwiftData
    @Bindable var schedule: Schedule
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            // SEKCOJA 1: Edycja informacji
            Section("Edytuj dane lokalizacji") {
                TextField("Adres zamieszkania", text: $schedule.address)
                    .textFieldStyle(.roundedBorder)
                
                DatePicker(
                                    "Ostatni wywóz",
                                    selection: $schedule.lastPickupDate,
                                    in: ...Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                
                VStack(alignment: .leading) {
                    Stepper("Wywóz co \(schedule.frequencyDays) dni", value: $schedule.frequencyDays, in: 1...60)
                }
                .padding(.vertical, 4)
            }
            
            Section("Ręczne ustawienie najbliższego wywozu") {
                Toggle("Własna data następnego wywozu", isOn: Binding(
                    get: { schedule.choosenNextPickupDate != nil },
                    set: { if !$0 { schedule.choosenNextPickupDate = nil } else { schedule.choosenNextPickupDate = Date() } }
                ))
                
                if schedule.choosenNextPickupDate != nil {
                    DatePicker(
                        "Wybierz datę",
                        selection: Binding(
                            get: { schedule.choosenNextPickupDate ?? Date() },
                            set: { schedule.choosenNextPickupDate = $0 }
                        ),
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
            }
        
            // SEKCJA 2: Harmonogram (uwzględniający Twoją logikę świąt)
            Section("Nadchodzące terminy") {
                ForEach(generateNextDates(count: 5), id: \.self) { date in
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text(date.formatted(
                            .dateTime.day().month(.abbreviated).year()
                            .locale(Locale(identifier: "pl_PL"))
                        ))
                        
                        if Calendar.current.isDate(date, inSameDayAs: schedule.nextPickupDate) {
                            Spacer()
                            Text("NAJBLIŻSZY")
                                .font(.caption2)
                                .padding(4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            if isOverdue {
                Section {
                    Button(action: updatePickupDateToLastPlanned) {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Potwierdź wykonanie wywozu")
                                    .fontWeight(.bold)
                                Text("Zaktualizuje datę ostatniego odbioru na \(schedule.nextPickupDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .listRowBackground(Color.clear) // Opcjonalnie, by wyróżnić przycisk
                }
            }
        }
        .navigationTitle("Szczegóły")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isOverdue: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let nextPickup = calendar.startOfDay(for: schedule.nextPickupDate)
        return nextPickup <= today
    }

    // Funkcja aktualizująca
    private func updatePickupDateToLastPlanned() {
        withAnimation {
            // 1. Przypisz datę ostatniego wywozu na tę, która właśnie minęła
            schedule.lastPickupDate = schedule.nextPickupDate
            
            // 2. Jeśli była ustawiona data ręczna (choosenNextPickupDate),
            // wyczyść ją, aby harmonogram wrócił do automatycznego liczenia
            if schedule.choosenNextPickupDate != nil {
                schedule.choosenNextPickupDate = nil
            }
            
            // SwiftData automatycznie zapisze zmiany w kontekście
        }
    }

    private func updatePickupDate() {
        withAnimation {
            schedule.lastPickupDate = Date()
        }
    }

    // Wykorzystujemy Twoją nową logikę szukania najbliższego dnia roboczego
    private func generateNextDates(count: Int) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        
        // 1. Punkt startowy: weź ręczną datę LUB wylicz pierwszą automatyczną
        var referenceDate: Date
        
        if let manualDate = schedule.choosenNextPickupDate {
            referenceDate = manualDate
        } else {
            let rawFirst = calendar.date(byAdding: .day, value: schedule.frequencyDays, to: schedule.lastPickupDate) ?? schedule.lastPickupDate
            referenceDate = calendar.findNearestWorkDay(for: rawFirst)
        }
        
        // Dodajemy pierwszy termin do listy
        dates.append(referenceDate)
        
        // 2. Kolejne terminy liczymy już zawsze od poprzedniego (z zachowaniem Twojej elastycznej logiki)
        for _ in 1..<(count) {
            if let rawNext = calendar.date(byAdding: .day, value: schedule.frequencyDays, to: referenceDate) {
                let adjustedNext = calendar.findNearestWorkDay(for: rawNext)
                dates.append(adjustedNext)
                referenceDate = adjustedNext
            }
        }
        
        return dates
    }
}
