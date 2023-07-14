import Foundation

// swiftlint:disable convenience_type
public class LFStyleGuide {
  
  public enum AppType: String {
    case avalanche = "Avalanche.app"
    case cardano = "Cardano.app"
  }
  
  static var appType: AppType {
    guard let type = AppType(rawValue: Bundle.main.bundleURL.lastPathComponent) else {
      fatalError("Not match app name, so please check it")
    }
    return type
  }
  
}
