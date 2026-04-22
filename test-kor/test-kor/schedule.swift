//
//  schedule.swift
//  test-kor
//
//  Created by Jakub Korcz on 25/03/2026.
//

import Foundation
import SwiftData

@Model
class Schedule {
    var address: String
    var frequencyDays: Int
    var lastPickupDate: Date
    // Używamy nazwy z DetailView:
    var choosenNextPickupDate: Date?
    
    // Obliczana właściwość, której używa Dashboard
    var hasManualDate: Bool {
        choosenNextPickupDate != nil
    }

    // Twoja główna logika obliczania "najbliższego" wywozu
    var nextPickupDate: Date {
        if let manual = choosenNextPickupDate {
            return manual
        }
        // Wykorzystuje rozszerzenie Calendar (patrz niżej)
        let calendar = Calendar.current
        let rawDate = calendar.date(byAdding: .day, value: frequencyDays, to: lastPickupDate) ?? lastPickupDate
        return calendar.findNearestWorkDay(for: rawDate)
    }

    // Dashboard używa 'effectiveNextDate' - możesz dodać alias dla wygody
    var effectiveNextDate: Date { nextPickupDate }

    init(address: String, frequencyDays: Int, lastPickupDate: Date) {
        self.address = address
        self.frequencyDays = frequencyDays
        self.lastPickupDate = lastPickupDate
    }
}
