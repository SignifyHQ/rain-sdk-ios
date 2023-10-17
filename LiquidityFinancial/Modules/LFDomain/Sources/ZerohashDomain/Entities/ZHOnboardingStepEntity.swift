import Foundation

// sourcery: AutoMockable
public enum ZHOnboardingStepTypeEnum: String {
  case createAccount = "zero_hash_create_account"
}

// sourcery: AutoMockable
public protocol ZHOnboardingStepEntity {
  var missingSteps: [String] { get }
  init(missingSteps: [String])
}

public extension ZHOnboardingStepEntity {
  func mapToEnum() -> [ZHOnboardingStepTypeEnum] {
    var steps = [ZHOnboardingStepTypeEnum]()
    steps = missingSteps.compactMap { ZHOnboardingStepTypeEnum(rawValue: $0) }
    return steps
  }
}
