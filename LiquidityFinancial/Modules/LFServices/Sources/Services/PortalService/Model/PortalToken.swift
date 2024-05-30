import Foundation

public enum PortalToken {
  case AVAX
  case sepoliaUSDC
  case mainnetAvalancheUSDC
  
  public var contractAddress: String {
    switch self {
    case .AVAX:
      ""
    case .sepoliaUSDC:
      "0x844d6973e50dd73f1dfcf64ce76e57c0c2d4d250"
    case .mainnetAvalancheUSDC:
      "0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e"
    }
  }
  
  public var symbol: String {
    switch self {
    case .AVAX:
      "AVAX"
    case .sepoliaUSDC, .mainnetAvalancheUSDC:
      "USDC"
    }
  }
  
  public var name: String {
    switch self {
    case .AVAX:
      "Avalanche"
    case .sepoliaUSDC, .mainnetAvalancheUSDC:
      "USDC"
    }
  }
}
