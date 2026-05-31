import Foundation
import SwiftData

@Model
final class RoutineItem {
    var id: UUID
    var title: String
    var minutesBefore: Int
    var isCompleted: Bool
    var date: Date
    var templateId: UUID

    init(id: UUID = UUID(), title: String, minutesBefore: Int, date: Date, templateId: UUID) {
        self.id = id
        self.title = title
        self.minutesBefore = minutesBefore
        self.isCompleted = false
        self.date = date
        self.templateId = templateId
    }
}
