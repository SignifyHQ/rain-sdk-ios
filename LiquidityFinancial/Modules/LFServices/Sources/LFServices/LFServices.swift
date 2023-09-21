import Foundation
import VGSShowSDK
import LFUtilities

// swiftlint:disable convenience_type
public class LFServices {
  
  static let environment = EnvironmentManager()
  
  public static let vgsShowSandBox: VGSShow = {
    VGSShow(
      id: Configs.VSGID.sandbox.id,
      environment: .sandbox
    )
  }()
  
  public static let vgsShowLive: VGSShow = {
    VGSShow(
      id: Configs.VSGID.live.id,
      environment: .live
    )
  }()
  
  public static let segmentKey: String = {
    switch environment.networkEnvironment {
    case .productionLive: return Configs.Segment.prodKey
    case .productionTest: return Configs.Segment.devKey
    }
  }()
  
}
