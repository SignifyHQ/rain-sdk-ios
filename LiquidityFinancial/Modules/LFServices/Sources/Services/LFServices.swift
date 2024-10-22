import Foundation
import VGSShowSDK
import LFUtilities
import EnvironmentService
import Factory

// swiftlint:disable convenience_type
public class LFServices {
  
  @LazyInjected(\.environmentService)
  static var environmentService
  
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
  
  public static var googleInfoFilePath: String? {
    let fileName: String = {
      switch environmentService.networkEnvironment {
      case .productionLive:
        LFUtilities.googleInfoFileNameProd
      case .productionTest:
        LFUtilities.googleInfoFileNameDev
      }
    }()
    
    return Bundle.main.path(forResource: fileName, ofType: "plist")
  }
  
  public static var vgsConfig: (id: String, env: String) {
    switch environmentService.networkEnvironment {
    case .productionLive:
      return (id: Configs.VSGID.live.id, env: VGSEnvironment.live.rawValue)
    case .productionTest:
      return (id: Configs.VSGID.sandbox.id, env: VGSEnvironment.sandbox.rawValue)
    }
  }
  
  public static var segmentKey: String {
    switch environmentService.networkEnvironment {
    case .productionLive: return Configs.Segment.prodKey
    case .productionTest: return Configs.Segment.devKey
    }
  }
}
