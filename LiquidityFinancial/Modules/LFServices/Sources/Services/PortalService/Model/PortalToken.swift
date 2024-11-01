import Foundation

public enum PortalToken {
  case AVAX
  case fujiAvalancheUSDC
  case mainnetAvalancheUSDC
  case fujiAvalancheWAVAX
  case mainnetAvalancheWAVAX
  
  public var contractAddress: String {
    switch self {
    case .AVAX:
      ""
    case .fujiAvalancheUSDC:
      "0xd856a0585da55e83d03ccb49ef09d180494cfbad"
    case .mainnetAvalancheUSDC:
      "0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e"
    case .fujiAvalancheWAVAX:
      "0x688af2a8422611b770b4e2ef55a7f50f0339cc65"
    case .mainnetAvalancheWAVAX:
      "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7"
    }
  }
  
  public var symbol: String {
    switch self {
    case .AVAX:
      "AVAX"
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC:
      "USDC"
    case .fujiAvalancheWAVAX, .mainnetAvalancheWAVAX:
      "WAVAX"
    }
  }
  
  public var name: String {
    switch self {
    case .AVAX:
      "Avalanche"
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC:
      "USDC"
    case .fujiAvalancheWAVAX, .mainnetAvalancheWAVAX:
      "Wrapped AVAX"
    }
  }
  
  public var conversionFactor: Int {
    switch self {
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC:
      6
    default:
      18
    }
  }
}
