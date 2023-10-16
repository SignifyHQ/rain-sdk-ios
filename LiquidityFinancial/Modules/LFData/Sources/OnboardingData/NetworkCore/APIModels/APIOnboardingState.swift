import Foundation

public struct APIOnboardingState: Decodable {
  public let missingSteps: [String]
  public init(missingSteps: [String]) {
    self.missingSteps = missingSteps
  }
}
