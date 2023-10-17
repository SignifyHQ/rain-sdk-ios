import Foundation

public struct APIZHOnboardingStep: Decodable {
  public let missingSteps: [String]
  
  public init(missingSteps: [String]) {
    self.missingSteps = missingSteps
  }
}
