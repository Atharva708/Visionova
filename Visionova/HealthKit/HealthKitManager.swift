import Foundation
import HealthKit

struct HealthDemographics {
    let age: Int?
    let gender: String?
}

struct HealthInsight: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let trend: String?
}

/// Wraps the limited HealthKit queries used by the app.
final class HealthKitManager {
    private let healthStore = HKHealthStore()
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    private let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

    func requestPermissions() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        let typesToShare: Set<HKSampleType> = [heartRateType]
        let typesToRead: Set<HKObjectType> = [
            sleepType,
            heartRateType,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        ]
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    func readBasicDemographics() async throws -> HealthDemographics {
        var age: Int?
        var gender: String?
        if let birth = try? healthStore.dateOfBirthComponents() {
            let calendar = Calendar.current
            if let birthDate = calendar.date(from: birth) {
                age = calendar.dateComponents([.year], from: birthDate, to: Date()).year
            }
        }
        if let biologicalSex = try? healthStore.biologicalSex().biologicalSex {
            gender = biologicalSex.localizedString
        }
        return HealthDemographics(age: age, gender: gender)
    }

    func fetchSleep() async throws -> Double {
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date())
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let total = samples?.compactMap { sample -> Double? in
                    guard let categorySample = sample as? HKCategorySample else { return nil }
                    return categorySample.endDate.timeIntervalSince(categorySample.startDate)
                }.reduce(0, +) ?? 0
                continuation.resume(returning: total / 3600)
            }
            healthStore.execute(query)
        }
    }

    func fetchHeartRate() async throws -> Double {
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -1, to: Date()), end: Date())
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, stats, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let quantity = stats?.averageQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                continuation.resume(returning: quantity.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }
}

private extension HKBiologicalSex {
    var localizedString: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        default: return "Unspecified"
        }
    }
}
