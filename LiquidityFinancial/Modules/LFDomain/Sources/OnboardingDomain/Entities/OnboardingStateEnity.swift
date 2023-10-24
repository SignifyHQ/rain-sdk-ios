import Foundation

public enum OnboardingMissingStep: String, Codable {
  case netSpendCreateAccount = "NET_SPEND_CREATE_ACCOUNT"
  case dashboardReview = "DASHBOARD_REVIEW"
  case cardProvision = "CARD_PROVISION"
  case zeroHashAccount = "ZERO_HASH_ACCOUNT"
  case accountReject = "ACCOUNT_REJECT"
  
  case identityQuestions = "identity_questions"
  case provideDocuments = "provide_documents"
  case primaryPersonKYCApprove = "primary_person_kyc_approve"
  case KYCData = "kyc_data"
  case acceptAgreement = "accept_agreement"
  case expectedUse = "expected_use"
  case identityScan = "identity_scan"
  case acceptFeatureAgreement = "accept_feature_agreement"
}

// sourcery: AutoMockable
public protocol OnboardingStateEnity {
  var missingSteps: [String] { get }
  init(missingSteps: [String])
}

public extension OnboardingStateEnity {
  func mapToEnum() -> [OnboardingMissingStep] {
    var steps = [OnboardingMissingStep]()
    steps = missingSteps.compactMap { OnboardingMissingStep(rawValue: $0) }
    return steps
  }
}
