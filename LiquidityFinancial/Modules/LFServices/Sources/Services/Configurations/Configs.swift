import Foundation
import VGSShowSDK
import LFUtilities

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
  
  enum Segment {
    static var prodKey: String {
      (try? LFConfiguration.value(for: "SEGMENT_PROD_KEY")) ?? .empty
    }
    
    static var devKey: String {
      (try? LFConfiguration.value(for: "SEGMENT_DEV_KEY")) ?? .empty
    }
  }
  
  enum RainConfig {
    static var prodPublicKey: String{
      (try? LFConfiguration.value(for: "RAIN_PROD_PUBLIC_KEY")) ?? .empty
    }
    
    static var devPublicKey: String{
      (try? LFConfiguration.value(for: "RAIN_DEV_PUBLIC_KEY")) ?? .empty
    }
  }
  
  enum DataDog {
    static var appID: String {
      "8e99898c-eda0-48b1-bf3e-71c5ce99e5df"
    }
    
    static var clientToken: String {
      "pub8fede038246db4623f73caba9e9e3873"
    }
  }
  
  enum Alchemy {
    static var prodKey: String {
      (try? LFConfiguration.value(for: "ALCHEMY_PROD_KEY")) ?? .empty
    }
    
    static var devKey: String {
      (try? LFConfiguration.value(for: "ALCHEMY_DEV_KEY")) ?? .empty
    }
  }
  
  enum PortalSwaps {
    static var prodKey: String {
      ""
    }
    
    static var devKey: String {
      "d40ff162-39f2-49b0-b7c7-5d27acee76c8"
    }
  }
  
  enum PortalNetwork {
    case avalancheMainnet
    case avalancheFuji
    
    var chainID: Int {
      switch self {
      case .avalancheMainnet:
        43_114
      case .avalancheFuji:
        43_113
      }
    }
    
    static func configRPC() -> [String: String] {
      [
        "eip155:43114": "https://avalanche-c-chain-rpc.publicnode.com",
        "eip155:43113": "https://avalanche-fuji-c-chain-rpc.publicnode.com"
      ]
    }
  }
  
  enum GooglePlaces {
    static func apiKey(for environment: NetworkEnvironment) -> String {
      if environment == .productionLive {
        return (try? LFConfiguration.value(for: "GOOGLE_PLACES_PROD_KEY")) ?? .empty
      }
      
      return (try? LFConfiguration.value(for: "GOOGLE_PLACES_DEV_KEY")) ?? .empty
    }
  }
}
