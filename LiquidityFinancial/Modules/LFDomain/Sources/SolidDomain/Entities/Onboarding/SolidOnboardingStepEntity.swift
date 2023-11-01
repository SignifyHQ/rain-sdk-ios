import Foundation

public enum SolidOnboardingTypeEnum: String {
  case createAccount = "solid_create_account"
  case accountRejected = "solid_account_rejected"
  case accountInReview = "solid_account_in_review"
}

// sourcery: AutoMockable
public protocol SolidOnboardingStepEntity {
  var processSteps: [String] { get }
}

public extension SolidOnboardingStepEntity {
  func mapToEnum() -> [SolidOnboardingTypeEnum] {
    var steps = [SolidOnboardingTypeEnum]()
    steps = processSteps.compactMap { SolidOnboardingTypeEnum(rawValue: $0) }
    return steps
  }
}
