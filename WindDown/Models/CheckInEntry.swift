import Foundation
import SwiftData

@Model
final class CheckInEntry {
    var id: UUID
    var date: Date
    var mood: Int
    var energy: Int
    var note: String?
    var aiInsight: String?

    init(id: UUID = UUID(), date: Date = Date(), mood: Int, energy: Int, note: String? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.energy = energy
        self.note = note
        self.aiInsight = nil
    }
}
