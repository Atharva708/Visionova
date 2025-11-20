import Foundation
import Combine
import AVFoundation
import Photos
import HealthKit

/// Tracks onboarding progression and permission states.
final class OnboardingManager: ObservableObject {
    enum Step: Int, CaseIterable {
        case welcome
        case permissions
        case summary
    }

    @Published var currentStep: Step = .welcome
    @Published var cameraGranted: Bool = false {
        didSet { defaults.set(cameraGranted, forKey: Keys.cameraGranted) }
    }
    @Published var photoGranted: Bool = false {
        didSet { defaults.set(photoGranted, forKey: Keys.photoGranted) }
    }
    @Published var healthGranted: Bool = false {
        didSet { defaults.set(healthGranted, forKey: Keys.healthGranted) }
    }
    @Published var healthOptional: Bool = false {
        didSet { defaults.set(healthOptional, forKey: Keys.healthOptional) }
    }
    @Published var hasAcceptedTerms: Bool = false {
        didSet { defaults.set(hasAcceptedTerms, forKey: Keys.acceptedTerms) }
    }
    @Published private(set) var hasFinishedFlow: Bool = false {
        didSet { defaults.set(hasFinishedFlow, forKey: Keys.finished) }
    }

    private let defaults = UserDefaults.standard

    init(healthAvailable: Bool = HKHealthStore.isHealthDataAvailable()) {
        let defaultHealthOptional = !healthAvailable
        self.cameraGranted = defaults.bool(forKey: Keys.cameraGranted)
        self.photoGranted = defaults.bool(forKey: Keys.photoGranted)
        self.healthGranted = defaults.bool(forKey: Keys.healthGranted)
        self.healthOptional = defaults.object(forKey: Keys.healthOptional) as? Bool ?? defaultHealthOptional
        self.hasAcceptedTerms = defaults.bool(forKey: Keys.acceptedTerms)
        self.hasFinishedFlow = defaults.bool(forKey: Keys.finished)
    }

    var isOnboardingComplete: Bool {
        hasFinishedFlow
    }

    func next() {
        if let nextStep = Step(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        } else {
            finish()
        }
    }

    func finish() {
        hasFinishedFlow = true
    }

    func reset(healthAvailable: Bool = HKHealthStore.isHealthDataAvailable()) {
        currentStep = .welcome
        cameraGranted = defaults.bool(forKey: Keys.cameraGranted)
        photoGranted = defaults.bool(forKey: Keys.photoGranted)
        healthGranted = defaults.bool(forKey: Keys.healthGranted)
        healthOptional = defaults.object(forKey: Keys.healthOptional) as? Bool ?? !healthAvailable
        hasAcceptedTerms = defaults.bool(forKey: Keys.acceptedTerms)
        hasFinishedFlow = defaults.bool(forKey: Keys.finished)
    }

    func skipHealthKit() {
        healthOptional = true
    }
}

private enum Keys {
    static let cameraGranted = "onboarding.cameraGranted"
    static let photoGranted = "onboarding.photoGranted"
    static let healthGranted = "onboarding.healthGranted"
    static let healthOptional = "onboarding.healthOptional"
    static let acceptedTerms = "onboarding.acceptedTerms"
    static let finished = "onboarding.finished"
}
