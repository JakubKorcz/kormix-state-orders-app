import Foundation
import SwiftData

@Model
class PickupHistory {
    var executionDate: Date
    var address: String
    var confirmedAt: Date

    init(executionDate: Date, address: String, confirmedAt: Date) {
        self.executionDate = executionDate
        self.address = address
        self.confirmedAt = confirmedAt
    }
}
