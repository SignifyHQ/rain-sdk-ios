import Foundation

// swiftlint:disable convenience_type identifier_name

public final class DataUtilities {
  
  static var target: Configs.Target!
  
  public static func initial(target: String) {
    if let target = Configs.Target(rawValue: target) {
      self.target = target
    } else {
      fatalError("Wrong the target name. It must right for setup the module")
    }
  }
  
}

extension DataUtilities {
  
  struct Configs {
    enum Target: String {
      case Avalanche
      case Cardano
    }
  }
  
}
