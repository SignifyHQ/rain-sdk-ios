import Foundation
// swiftlint:disable convenience_type identifier_name

public final class LFStyleGuide {
  
  public static var target: Configs.Target!
  
  public static func initial(target: String) {
    if let target = Configs.Target(rawValue: target) {
      self.target = target
    } else {
      fatalError("Wrong the target name. It must right for setup the module")
    }
  }
  
}

extension LFStyleGuide {
  
  public struct Configs {
    public enum Target: String {
      case Avalanche
      case Cardano
      case DogeCard
      case CauseCard
      case PrideCard
      case DogeCardNobank
      case PawsCard
    }
  }
  
}
