import Foundation

public enum OnboardingMissingStep: String, Codable {
  case identityQuestions = "identity_questions"
  case provideDocuments = "provide_documents"
  case primaryPersonKYCApprove = "primary_person_kyc_approve"
  case KYCData = "kyc_data"
  case acceptAgreement = "accept_agreement"
  case expectedUse = "expected_use"
  case identityScan = "identity_scan"
}

public struct APIOnboardingState: Decodable {
  public let missingSteps: [String]
  
  public func mapToEnum() -> [OnboardingMissingStep] {
    var steps = [OnboardingMissingStep]()
    steps = missingSteps.compactMap { OnboardingMissingStep(rawValue: $0) }
    return steps
  }
}
