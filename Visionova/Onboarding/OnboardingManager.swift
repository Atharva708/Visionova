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
    @Published var cameraGranted = false
    @Published var photoGranted = false
    @Published var healthGranted = false
    @Published var hasAcceptedTerms = false
    @Published private(set) var hasFinishedFlow = false

    var isOnboardingComplete: Bool {
        hasFinishedFlow
    }

    func next() {
        if let nextStep = Step(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        } else if canFinish {
            hasFinishedFlow = true
        }
    }

    func reset() {
        currentStep = .welcome
        cameraGranted = false
        photoGranted = false
        healthGranted = false
        hasAcceptedTerms = false
        hasFinishedFlow = false
    }

    private var canFinish: Bool {
        cameraGranted && photoGranted && healthGranted && hasAcceptedTerms
    }
}
