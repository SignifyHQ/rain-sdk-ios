import Foundation

// swiftlint:disable convenience_type identifier_name

public final class NetworkUtilities {
  
  static var target: Configs.Target!
  
  public static func initial(target: String) {
    if let target = Configs.Target(rawValue: target) {
      self.target = target
    } else {
      fatalError("Wrong the target name. It must right for setup the module")
    }
  }
  
  public static var productID: String {
    switch NetworkUtilities.target {
    case .Avalanche: return APIConstants.avalencheID
    case .Cardano: return APIConstants.cardanoID
    case .DogeCard, .DogeCardNobank: return APIConstants.dogeCardID
    case .CauseCard: return APIConstants.causeCardID
    case .PrideCard: return APIConstants.prideCardID
    case .PawsCard: return APIConstants.pawsCardID
    case .none:
      fatalError("Wrong the target name. It must right for setup the API")
    }
  }
}

extension NetworkUtilities {
  
  struct Configs {
    enum Target: String {
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
