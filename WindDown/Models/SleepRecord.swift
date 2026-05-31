import Foundation
import SwiftData

@Model
final class SleepRecord {
    var id: UUID
    var date: Date
    var bedtime: Date?
    var targetBedtime: Date
    var routineScore: Double

    init(id: UUID = UUID(), date: Date, bedtime: Date? = nil, targetBedtime: Date, routineScore: Double) {
        self.id = id
        self.date = date
        self.bedtime = bedtime
        self.targetBedtime = targetBedtime
        self.routineScore = routineScore
    }
}
