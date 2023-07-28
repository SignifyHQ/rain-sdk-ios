import Foundation
import VGSShowSDK

//swiftlint:disable convenience_type
public class LFServices {
  
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
  
}
