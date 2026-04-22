//
//  Calendar.swift
//  test-kor
//
//  Created by Jakub Korcz on 25/03/2026.
//

import Foundation

extension Calendar {
    func isWorkDay(_ date: Date) -> Bool {
        let components = self.dateComponents([.year, .month, .day, .weekday], from: date)
        let year = components.year!
        
        // 1. Weekendy (Niedziela = 1, Sobota = 7)
        if components.weekday == 1 || components.weekday == 7 {
            return false
        }
        
        // 2. Stałe święta w Polsce
        let fixedHolidays = [
            (1, 1),   // Nowy Rok
            (1, 6),   // Trzech Króli
            (5, 1),   // 1 Maja
            (5, 3),   // 3 Maja
            (8, 15),  // Wniebowzięcie
            (11, 1),  // Wszystkich Świętych
            (11, 11), // Niepodległości
            (12, 25), // Boże Narodzenie
            (12, 26)  // Boże Narodzenie
        ]
        
        if fixedHolidays.contains(where: { $0.0 == components.month && $0.1 == components.day }) {
            return false
        }
        
        // 3. Święta ruchome (Wielkanoc i pochodne)
        let easter = calculateEaster(year: year)
        let easterMonday = self.date(byAdding: .day, value: 1, to: easter)!
        let corpusChristi = self.date(byAdding: .day, value: 60, to: easter)! // Boże Ciało
        
        let movingHolidays = [easter, easterMonday, corpusChristi]
        
        for holiday in movingHolidays {
            if self.isDate(date, inSameDayAs: holiday) {
                return false
            }
        }
        
        return true
    }
    
    // Algorytm Gaussa do wyznaczania daty Wielkanocy
    private func calculateEaster(year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return self.date(from: components)!
    }
    
    // Szukanie najbliższego dnia roboczego
    func findNearestWorkDay(for date: Date) -> Date {
        // 1. Jeśli sama data jest dniem roboczym, zwróć ją od razu
        if isWorkDay(date) {
            return date
        }
        
        var offset = 1
        
        // 2. Szukaj w pętli zwiększając dystans (promień) od daty bazowej
        while true {
            // Sprawdź dzień PRZED (offset dni wstecz)
            if let dayBefore = self.date(byAdding: .day, value: -offset, to: date),
               isWorkDay(dayBefore) {
                return dayBefore
            }
            
            // Sprawdź dzień PO (offset dni w przód)
            if let dayAfter = self.date(byAdding: .day, value: offset, to: date),
               isWorkDay(dayAfter) {
                return dayAfter
            }
            
            // Jeśli nie znaleziono, zwiększ dystans o 1 i szukaj dalej (np. -2, potem +2)
            offset += 1
            
            // Zabezpieczenie przed nieskończoną pętlą (np. max 14 dni szukania)
            if offset > 14 { return date }
        }
    }
}
