import SwiftUI
import SwiftData

struct PickupHistoryView: View {
    @Query(sort: [
        SortDescriptor(\PickupHistory.executionDate, order: .reverse),
        SortDescriptor(\PickupHistory.confirmedAt, order: .reverse)
    ])
    private var historyRecords: [PickupHistory]

    var body: some View {
        List {
            ForEach(historyRecords) { record in
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.address)
                        .font(.headline)
                    HStack {
                        Label("Wykonany:", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(record.executionDate.formatted(
                            .dateTime.day().month(.abbreviated).year()
                            .locale(Locale(identifier: "pl_PL"))
                        ))
                        .fontWeight(.bold)
                    }
                    HStack {
                        Label("Potwierdzony:", systemImage: "hand.tap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(record.confirmedAt.formatted(
                            .dateTime.day().month(.abbreviated).year().hour().minute()
                            .locale(Locale(identifier: "pl_PL"))
                        ))
                        .fontWeight(.bold)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Historia")
        .overlay {
            if historyRecords.isEmpty {
                ContentUnavailableView("Brak historii",
                    systemImage: "clock.badge.questionmark",
                    description: Text("Potwierdź pierwszy wywóz, aby zobaczyć historię."))
            }
        }
    }
}
