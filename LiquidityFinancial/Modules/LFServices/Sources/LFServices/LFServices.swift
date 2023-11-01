import Foundation
import VGSShowSDK
import LFUtilities

// swiftlint:disable convenience_type
public class LFServices {
  
  static let environment = EnvironmentManager()
  
  public struct Configuration {
    var baseURL: String
    
    public init(baseURL: String) {
      self.baseURL = baseURL
    }
    
    static var `default` = Configuration(baseURL: "")
  }
  
  public static var config: Configuration = .default
  public static func initial(config: Configuration) {
    Self.config = config
  }
  
  public static var vgsConfig: (id: String, env: String) = {
    switch environment.networkEnvironment {
    case .productionLive:
      return (id: Configs.VSGID.live.id, env: VGSEnvironment.live.rawValue)
    case .productionTest:
      return (id: Configs.VSGID.sandbox.id, env: VGSEnvironment.sandbox.rawValue)
    }
  }()
  
  public static let segmentKey: String = {
    switch environment.networkEnvironment {
    case .productionLive: return Configs.Segment.prodKey
    case .productionTest: return Configs.Segment.devKey
    }
  }()
  
}
