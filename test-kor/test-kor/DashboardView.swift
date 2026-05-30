//
//  DashboardView.swift
//  test-kor
//
//  Created by Jakub Korcz on 25/03/2026.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Schedule.lastPickupDate, order: .reverse)
    private var schedules: [Schedule]
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddScreen = false
    @State private var showingHistory = false
    @State private var showingPinSettings = false
    
    private var sortedSchedules: [Schedule] {
        schedules.sorted { $0.effectiveNextDate < $1.effectiveNextDate }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedSchedules) { schedule in
                    NavigationLink(destination: DetailView(schedule: schedule)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(schedule.address)
                                    .font(.headline)
                                
                                
                                Label("\(schedule.frequencyDays) dni", systemImage: "repeat")
                            }
                            Spacer()
                                
                            VStack{
                                HStack{
                                    Text("Ostatni:")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(schedule.lastPickupDate.formatted(
                                        .dateTime.day().month(.abbreviated).year()
                                        .locale(Locale(identifier: "pl_PL"))
                                    ))
                                        .fontWeight(.bold)
                                        .foregroundStyle(textColor(for: schedule))
                                }
                                
                                HStack{
                                    Text("Następny:")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(schedule.effectiveNextDate.formatted(
                                        .dateTime.day().month(.abbreviated).year()
                                        .locale(Locale(identifier: "pl_PL"))
                                    ))
                                        .fontWeight(.bold)
                                        .foregroundStyle(textColor(for: schedule))
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteSchedule)
            }
            .navigationTitle("KORMIX Planer")
            .navigationBarTitleDisplayMode(.inline) 
            .overlay {
                if schedules.isEmpty {
                    ContentUnavailableView("Brak adresów",
                        systemImage: "trash.slash",
                        description: Text("Dodaj swój pierwszy adres, aby śledzić wywóz."))
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title3)
                    }
                    Button(action: { showingPinSettings = true }) {
                        Image(systemName: "gearshape")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddScreen = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddScreen) {
                AddScheduleView()
            }
            .sheet(isPresented: $showingHistory) {
                NavigationStack {
                    PickupHistoryView()
                }
            }
            .sheet(isPresented: $showingPinSettings) {
                NavigationStack {
                    PinSettingsView()
                }
            }
        }
    }

    private func deleteSchedule(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(schedules[index])
        }
    }
    
    // Wydzielona logika koloru dla czytelności
    private func textColor(for schedule: Schedule) -> Color {
        if schedule.hasManualDate {
            return .orange
        }
        
        // Sprawdzenie czy data jest przed dzisiejszym początkiem dnia
        let calendar = Calendar.current
        if calendar.startOfDay(for: schedule.effectiveNextDate) < calendar.startOfDay(for: Date()) {
            return .red
        }
        
        return .primary
    }
}
