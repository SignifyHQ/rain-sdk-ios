import Foundation
import RainDomain

public struct APIRainOnboardingMissingSteps: Decodable {
  public let processSteps: [String]
}

extension APIRainOnboardingMissingSteps: RainOnboardingMissingStepsEntity {}
