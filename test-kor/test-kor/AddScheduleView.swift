//
//  AddScheduleView.swift
//  test-kor
//
//  Created by Jakub Korcz on 25/03/2026.
//

import SwiftUI
import SwiftData

struct AddScheduleView: View {
    // Odniesienie do kontekstu bazy danych, aby móc zapisywać
    @Environment(\.modelContext) private var modelContext
    // Pozwala zamknąć ten ekran po zapisaniu danych
    @Environment(\.dismiss) private var dismiss
    
    // Pola formularza (State)
    @State private var address: String = ""
    @State private var lastPickupDate: Date = Date()
    @State private var frequencyDays: Int = 14 // domyślnie co 2 tygodnie
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Lokalizacja")) {
                    TextField("Wpisz adres (np. Polna 5)", text: $address)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Ustawienia wywozu")) {
                    DatePicker(
                        "Ostatni wywóz",
                        selection: $lastPickupDate,
                        in: ...Date(), // Nie pozwalamy wybierać dat z przyszłości
                        displayedComponents: .date
                    )
                    
                    VStack(alignment: .leading) {
                        Text("Częstotliwość: co \(frequencyDays) dni")
                        Stepper("Zmień częstotliwość", value: $frequencyDays, in: 1...60)
                            .labelsHidden()
                    }
                }
                
                Section {
                    // Podgląd następnego wywozu w czasie rzeczywistym
                    HStack {
                        Text("Następny termin:")
                        Spacer()
                        Text(calculateNextDate().formatted(date: .long, time: .omitted))
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
            }
            .navigationTitle("Dodaj adres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") {
                        saveNewSchedule()
                    }
                    .disabled(address.trimmingCharacters(in: .whitespaces).isEmpty)
                    .bold()
                }
            }
        }
    }
    
    private func calculateNextDate() -> Date {
        let calendar = Calendar.current
        let rawDate = calendar.date(byAdding: .day, value: frequencyDays, to: lastPickupDate) ?? Date()
        return calendar.findNearestWorkDay(for: rawDate)
    }
    
    // Zapis do SQLite
    private func saveNewSchedule() {
        let newSchedule = Schedule(
            address: address,
            frequencyDays: frequencyDays, lastPickupDate: lastPickupDate
        )
        
        // SwiftData zajmuje się resztą - dane trafią do SQLite
        modelContext.insert(newSchedule)
        
        // Powrót do Dashboardu
        dismiss()
    }
}

#Preview {
    AddScheduleView()
        .modelContainer(for: Schedule.self, inMemory: true)
}
