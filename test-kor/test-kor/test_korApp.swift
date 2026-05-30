import SwiftUI

@main
struct test_korApp: App {
    @State private var isUnlocked = !PinManager.isPinSet
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .modelContainer(for: [Schedule.self, PickupHistory.self])
                .environment(\.locale, Locale(identifier: "pl_PL"))
                .tint(Color(red: 0.0, green: 0.4, blue: 0.0))
                .fullScreenCover(isPresented: .init(
                    get: { !isUnlocked && PinManager.isPinSet },
                    set: { if !$0 { isUnlocked = true } }
                )) {
                    PinLockView(onUnlock: { isUnlocked = true })
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .background || scenePhase == .inactive {
                        isUnlocked = false
                    }
                }
        }
    }
}
