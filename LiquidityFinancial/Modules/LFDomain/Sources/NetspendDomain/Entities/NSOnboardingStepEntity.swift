import Foundation

public enum NSOnboardingTypeEnum: String {
  case createAccount = "netspend_create_account"
  case accountRejected = "netspend_account_rejected"
  case identityQuestions = "identity_questions"
  case provideDocuments = "provide_documents"
  case primaryPersonKYCApprove = "primary_person_kyc_approve"
  case KYCData = "kyc_data"
  case acceptAgreement = "accept_agreement"
  case expectedUse = "expected_use"
  case identityScan = "identity_scan"
  case acceptFeatureAgreement = "accept_feature_agreement"
}

public protocol NSOnboardingStepEntity {
  var processSteps: [String] { get }
}

public extension NSOnboardingStepEntity {
  func mapToEnum() -> [NSOnboardingTypeEnum] {
    var steps = [NSOnboardingTypeEnum]()
    steps = processSteps.compactMap { NSOnboardingTypeEnum(rawValue: $0) }
    return steps
  }
}
