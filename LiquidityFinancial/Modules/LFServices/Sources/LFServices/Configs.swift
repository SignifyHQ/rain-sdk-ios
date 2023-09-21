import Foundation
import VGSShowSDK
import LFUtilities

//swiftlint:disable force_try
enum Configs {
  
  enum NetSpend {
    static let sdkIdCert = "NS-CERT-ae0bca62bd0244949a171ebf0ba49818"
    static let sdkIdProd = "NS-PROD-ae0bca62bd0244949a171ebf0ba49818"
    
  }
  
  enum VSGID: String {
    case sandbox = "tntbevlgikb"
    case live = "tntpsikpeyn"
    
    var id: String {
      rawValue
    }
  }
  
  enum Intercom {
    static var apiKeySandBox: String {
      "ios_sdk-b6ed092c4b3547da09843f567fd4867ecc2daddf"
    }
    
    static var apiKey: String {
      "ios_sdk-d6c27e3f898e20d95763e7d99ef8dd0e2e9dc135"
    }
    
    static var appIDSandBox: String {
      "ursuzkbg"
    }
    
    static var appID: String {
      "q9956v3x"
    }
  }
  
  enum Segment {
    static var prodKey: String {
      return try! LFConfiguration.value(for: "SEGMENT_PROD_KEY")
    }
    
    static var devKey: String {
      return try! LFConfiguration.value(for: "SEGMENT_DEV_KEY")
    }
  }
}
