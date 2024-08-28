import Foundation

public enum OnboardingProcessTypeEnum: String {
  case NETSPEND = "NETSPEND"
  case ZEROHASH = "ZERO_HASH"
  case LIQUIDITY = "LIQUIDITY"
}

// sourcery: AutoMockable
public protocol OnboardingProcess {
  var processSteps: [String] { get }
}

public extension OnboardingProcess {
  func mapToEnum() -> [OnboardingProcessTypeEnum] {
    var steps = [OnboardingProcessTypeEnum]()
    steps = processSteps.compactMap { OnboardingProcessTypeEnum(rawValue: $0) }
    return steps
  }
}
