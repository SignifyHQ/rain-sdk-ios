import Foundation

public enum PortalToken {
  case AVAX
  case SepoliaUSDC
  case MainnetAvalancheUSDC
  
  public var contractAddress: String {
    switch self {
    case .AVAX:
      ""
    case .SepoliaUSDC:
      "0x844d6973e50dd73f1dfcf64ce76e57c0c2d4d250"
    case .MainnetAvalancheUSDC:
      "0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e"
    }
  }
  
  public var symbol: String {
    switch self {
    case .AVAX:
      "AVAX"
    case .SepoliaUSDC, .MainnetAvalancheUSDC:
      "USDC"
    }
  }
  
  public var name: String {
    switch self {
    case .AVAX:
      "Avalanche"
    case .SepoliaUSDC, .MainnetAvalancheUSDC:
      "USDC"
    }
  }
}
