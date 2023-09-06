import Foundation

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
}

// MARK: - EnvironmentManager
public class EnvironmentManager: ObservableObject {
  public init() {}
  
  @Published public var networkEnvironment: NetworkEnvironment = {
    let environmentSelection = UserDefaults.environmentSelection
    if let environment = NetworkEnvironment(rawValue: environmentSelection) {
      return environment
    }
    return .productionTest
  }() {
    didSet {
      UserDefaults.environmentSelection = networkEnvironment.rawValue
    }
  }
}
