import Foundation
import LFUtilities

// MARK: - EnvironmentService
public protocol EnvironmentServiceProtocol {
  var networkEnvironment: NetworkEnvironment { get set }
  func toggleEnvironment()
}

public class EnvironmentService: EnvironmentServiceProtocol, ObservableObject {
  
  public init() {
    self.networkEnvironment = EnvironmentService.loadEnvironment(value: UserDefaults.environmentSelection)
  }
  
  public var networkEnvironment: NetworkEnvironment {
    get {
      let value = EnvironmentService.loadEnvironment(value: UserDefaults.environmentSelection)
      log.debug("EnvironmentService get mode \(value)")
      return value
    }
    set {
      log.info("EnvironmentService set mode \(newValue.rawValue)")
      UserDefaults.environmentSelection = newValue.rawValue
      NotificationCenter.default.post(
        name: NSNotification.Name.environmentChanage,
        object: nil,
        userInfo: [NSNotification.Name.environmentChanage.rawValue: newValue]
      )
    }
  }
  
  public func toggleEnvironment() {
    networkEnvironment = networkEnvironment == .productionLive ? .productionTest : .productionLive
  }
  
  private static func loadEnvironment(value: String) -> NetworkEnvironment {
    return NetworkEnvironment(rawValue: value) ?? NetworkEnvironment.defaultEnvironment
  }
}
