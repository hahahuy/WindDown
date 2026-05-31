import SwiftUI

struct RoutineItemRow: View {
    let item: RoutineItem
    let bedtime: Date
    let onToggle: () -> Void

    private var scheduledTime: String {
        let date = NotificationScheduler.notificationDate(for: item, bedtime: bedtime)
        return date.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .strikethrough(item.isCompleted)
                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    Text(scheduledTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
