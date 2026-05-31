import Foundation
import SwiftData

struct TemplateItem: Codable {
    var title: String
    var minutesBefore: Int
}

@Model
final class RoutineTemplate {
    var id: UUID
    var name: String
    var items: [TemplateItem]
    var isBuiltIn: Bool

    init(id: UUID = UUID(), name: String, items: [TemplateItem], isBuiltIn: Bool = false) {
        self.id = id
        self.name = name
        self.items = items
        self.isBuiltIn = isBuiltIn
    }

    static let builtIn: [RoutineTemplate] = [
        RoutineTemplate(
            name: "Night Owl Reform",
            items: [
                TemplateItem(title: "Dim lights", minutesBefore: 90),
                TemplateItem(title: "Put phone down", minutesBefore: 60),
                TemplateItem(title: "Brush teeth", minutesBefore: 40),
                TemplateItem(title: "Journal prompt", minutesBefore: 30),
                TemplateItem(title: "Lay out clothes", minutesBefore: 15),
                TemplateItem(title: "Lights out", minutesBefore: 0),
            ],
            isBuiltIn: true
        ),
        RoutineTemplate(
            name: "Busy Parent",
            items: [
                TemplateItem(title: "Kids to bed", minutesBefore: 60),
                TemplateItem(title: "Tidy kitchen", minutesBefore: 45),
                TemplateItem(title: "Prep tomorrow's bag", minutesBefore: 30),
                TemplateItem(title: "Skincare", minutesBefore: 15),
                TemplateItem(title: "Lights out", minutesBefore: 0),
            ],
            isBuiltIn: true
        ),
        RoutineTemplate(
            name: "Athlete Recovery",
            items: [
                TemplateItem(title: "Foam roll / stretch", minutesBefore: 60),
                TemplateItem(title: "Protein shake", minutesBefore: 45),
                TemplateItem(title: "Cold shower", minutesBefore: 30),
                TemplateItem(title: "Review tomorrow's training", minutesBefore: 15),
                TemplateItem(title: "Lights out", minutesBefore: 0),
            ],
            isBuiltIn: true
        ),
    ]
}
