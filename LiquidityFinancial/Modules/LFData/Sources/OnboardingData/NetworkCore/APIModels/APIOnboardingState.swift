import Foundation

public struct APIOnboardingState: Codable {
  public let missingSteps: [String]
  
  enum CodingKeys: String, CodingKey {
    case missingSteps = "missing_steps"
  }
}
