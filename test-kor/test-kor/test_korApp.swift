//
//  test_korApp.swift
//  test-kor
//
//  Created by Jakub Korcz on 25/03/2026.
//

import SwiftUI

@main
struct test_korApp: App {
    var body: some Scene {
        WindowGroup {
           DashboardView()
                .modelContainer(for: Schedule.self)
                .environment(\.locale, Locale(identifier: "pl_PL"))
                .tint(Color(red: 0.0, green: 0.4, blue: 0.0))
        }
    }
}
