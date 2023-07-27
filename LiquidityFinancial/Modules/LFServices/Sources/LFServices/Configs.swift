import Foundation
import VGSShowSDK

public enum Configs {
  
  enum NetSpend {
    static let sdkId = "NS-CERT-ae0bca62bd0244949a171ebf0ba49818"
  }
  
  public enum VSGID: String {
    case sandbox = "tntbevlgikb"
    case live = "tntpsikpeyn"
    
    var id: String {
      rawValue
    }
  }
  
}

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
