import Foundation

final class OpenRouterService {
    private let apiKey: String
    private let model: String
    private let endpoint = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    enum ServiceError: Error {
        case noContent
        case httpError(Int)
    }

    init(apiKey: String, model: String = "mistralai/mistral-7b-instruct:free") {
        self.apiKey = apiKey
        self.model = model
    }

    static func buildPrompt(entries: [CheckInEntry], records: [SleepRecord]) -> String {
        var lines = ["Here is my sleep and mood data for the past week. Give me a short, actionable insight (2-3 sentences).\n"]
        for entry in entries {
            let dateStr = entry.date.formatted(date: .abbreviated, time: .omitted)
            var line = "\(dateStr): mood: \(entry.mood)/5, energy: \(entry.energy)/5"
            if let note = entry.note { line += ", note: \(note)" }
            lines.append(line)
        }
        for record in records {
            let dateStr = record.date.formatted(date: .abbreviated, time: .omitted)
            lines.append("\(dateStr): routine completion: \(record.routineScore)")
        }
        return lines.joined(separator: "\n")
    }

    static func parseContent(from data: Data) throws -> String {
        struct Response: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String }
                let message: Message
            }
            let choices: [Choice]
        }
        let response = try JSONDecoder().decode(Response.self, from: data)
        guard let content = response.choices.first?.message.content else {
            throw ServiceError.noContent
        }
        return content
    }

    func fetchInsight(entries: [CheckInEntry], records: [SleepRecord]) async throws -> String {
        let prompt = Self.buildPrompt(entries: entries, records: records)
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw ServiceError.httpError(http.statusCode)
        }
        return try Self.parseContent(from: data)
    }
}
