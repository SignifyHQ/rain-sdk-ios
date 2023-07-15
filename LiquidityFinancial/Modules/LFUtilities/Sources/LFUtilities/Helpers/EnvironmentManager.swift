import Foundation

public enum NetworkEnvironment: String, Hashable {
  case productionTest
  case productionLive
}

// MARK: - EnvironmentManager
public class EnvironmentManager: ObservableObject {
  public init() {}
  
  @Published public var networkEnvironment: NetworkEnvironment = {
    let environmentSelection = UserDefaults.environmentSelection
    if let environment = NetworkEnvironment(rawValue: environmentSelection) {
      return environment
    }
  #if DEBUG
    return .productionTest
  #else
    return .productionLive
  #endif
  }() {
    didSet {
      UserDefaults.environmentSelection = networkEnvironment.rawValue
      // TODO: Will be implemented later
      //      if userManager.loggedIn {
      //        userManager.logout()
      //      }
    }
  }
}
