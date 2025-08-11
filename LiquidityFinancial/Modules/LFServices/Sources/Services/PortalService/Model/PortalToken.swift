import Foundation

public enum PortalToken {
  case AVAX
  case fujiAvalancheUSDC
  case mainnetAvalancheUSDC
  case fujiAvalancheUSDT
  case mainnetAvalancheUSDT
  case fujiAvalancheUSDTE
  case mainnetAvalancheUSDTE
  case fujiAvalancheWAVAX
  case mainnetAvalancheWAVAX
  case fujiAvalancheWYST
  case mainnetAvalancheWYST
  
  public var contractAddress: String {
    switch self {
    case .AVAX:
      "0x0000000000000000000000000000000000000000"
    case .fujiAvalancheUSDC:
      "0xd856a0585da55e83d03ccb49ef09d180494cfbad"
    case .mainnetAvalancheUSDC:
      "0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e"
    case .fujiAvalancheUSDT:
      "usdt" // Using a placeholder value here since USDT is not supported in dev currently
    case .mainnetAvalancheUSDT:
      "0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7"
    case .fujiAvalancheUSDTE:
      "usdte" // Using a placeholder value here since USDT.e is not supported in dev currently
    case .mainnetAvalancheUSDTE:
      "0xc7198437980c041c805a1edcba50c1ce5db95118"
    case .fujiAvalancheWAVAX:
      "0x688af2a8422611b770b4e2ef55a7f50f0339cc65"
    case .mainnetAvalancheWAVAX:
      "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7"
    case .fujiAvalancheWYST:
      "0x3894374b3ffd1DB45b760dD094963Dd1167e5568"
    case .mainnetAvalancheWYST:
      "update"
    }
  }
  
  public var symbol: String {
    switch self {
    case .AVAX:
      "AVAX"
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC:
      "USDC"
    case .fujiAvalancheUSDT, .mainnetAvalancheUSDT:
      "USDT"
    case .fujiAvalancheUSDTE, .mainnetAvalancheUSDTE:
      "USDTE"
    case .fujiAvalancheWAVAX, .mainnetAvalancheWAVAX:
      "WAVAX"
    case .fujiAvalancheWYST, .mainnetAvalancheWYST:
      "WYST"
    }
  }
  
  public var name: String {
    switch self {
    case .AVAX:
      "Avalanche"
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC:
      "USDC"
    case .fujiAvalancheUSDT, .mainnetAvalancheUSDT:
      "USDT"
    case .fujiAvalancheUSDTE, .mainnetAvalancheUSDTE:
      "USDTE"
    case .fujiAvalancheWAVAX, .mainnetAvalancheWAVAX:
      "Wrapped AVAX"
    case .fujiAvalancheWYST, .mainnetAvalancheWYST:
      "WYST"
    }
  }
  
  public var conversionFactor: Int {
    switch self {
    case .fujiAvalancheUSDC, .mainnetAvalancheUSDC, .fujiAvalancheUSDT, .mainnetAvalancheUSDT, .fujiAvalancheUSDTE, .mainnetAvalancheUSDTE:
      6
    default:
      18
    }
  }
}
