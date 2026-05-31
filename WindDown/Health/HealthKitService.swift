import Foundation
import HealthKit
import SwiftData

final class HealthKitService {
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestPermission() async -> Bool {
        guard isAvailable else { return false }
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: [sleepType])
            return true
        } catch {
            return false
        }
    }

    func fetchLastNightSleep() async -> (start: Date, end: Date)? {
        guard isAvailable else { return nil }
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKCategorySample else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: (sample.startDate, sample.endDate))
            }
            store.execute(query)
        }
    }

    func writeSleepRecord(targetBedtime: Date, routineScore: Double, context: ModelContext) async {
        let sleep = await fetchLastNightSleep()
        let record = SleepRecord(
            date: Calendar.current.startOfDay(for: Date()),
            bedtime: sleep?.start,
            targetBedtime: targetBedtime,
            routineScore: routineScore
        )
        context.insert(record)
        try? context.save()
    }
}
