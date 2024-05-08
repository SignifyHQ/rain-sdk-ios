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
  
  enum DataDog {
    static var appID: String {
      "4af1360f-bb0f-456f-b267-b34a63c4b9b4"
    }
    
    static var clientToken: String {
      "pub691559048fc10b3b4d3096efed1e69be"
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
    case ethSepolia
    case ethGoerli
    case ethMainnet
    case polygonMumbai
    case polygonMainnet
    
    var chainID: Int {
      switch self {
      case .ethSepolia:
        return 11_155_111
      case .ethGoerli:
        return 5
      case .ethMainnet:
        return 1
      case .polygonMumbai:
        return 80_001
      case .polygonMainnet:
        return 137
      }
    }
    
    static func configRPC(alchemyAPIKey: String) -> [String: String] {
      [
        "eip155:1": "https://eth-mainnet.g.alchemy.com/v2/\(alchemyAPIKey)",
        "eip155:11155111": "https://eth-sepolia.g.alchemy.com/v2/\(alchemyAPIKey)"
      ]
    }
  }
}
