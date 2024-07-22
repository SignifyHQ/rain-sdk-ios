import Foundation

public enum PortalToken {
  case AVAX
  case fujiAvalancheUSDC
  case mainnetAvalancheUSDC
  
  public var contractAddress: String {
    switch self {
    case .AVAX:
      ""
    case .fujiAvalancheUSDC:
      "0xd856a0585da55e83d03ccb49ef09d180494cfbad"
    case .mainnetAvalancheUSDC:
      "0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e"
    }
  }
  
  public var symbol: String {
    switch self {
    case .AVAX:
      "AVAX"
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC:
      "USDC"
    }
  }
  
  public var name: String {
    switch self {
    case .AVAX:
      "Avalanche"
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC:
      "USDC"
    }
  }
}
