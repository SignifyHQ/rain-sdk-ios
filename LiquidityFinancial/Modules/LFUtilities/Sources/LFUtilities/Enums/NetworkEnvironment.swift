import Foundation

// MARK: - Enum Type
public enum NetworkEnvironment: String, Hashable {
  case productionTest
  case productionLive
  
  public var title: String {
    switch self {
    case .productionTest:
      return "Dev"
    case .productionLive:
      return "Live"
    }
  }
  
  public static var defaultEnvironment: NetworkEnvironment {
#if DEBUG
    return .productionTest
#else
    return .productionLive
#endif
  }
}
