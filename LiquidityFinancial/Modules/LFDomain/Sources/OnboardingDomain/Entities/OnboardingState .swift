import Foundation

public protocol OnboardingState {
  var missingSteps: [String] { get }
}
