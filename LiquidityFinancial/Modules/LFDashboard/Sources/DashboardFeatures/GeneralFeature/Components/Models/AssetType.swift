import SwiftUI
import LFStyleGuide
import LFUtilities

public enum AssetType: String {
  case usd = "USD"
  case usdc = "USDC"
  case usdt = "USDT"
  case usdte = "USDTE"
  case wavax = "WAVAX"
  case avax = "AVAX"
  case frnt = "FRNT"
  case cardano = "ADA"
  case doge = "DOGE"
  
  public var symbol: String? {
    rawValue
  }
  
  public var name: String? {
    switch self {
    case .usdt:
      "Tether"
    case .wavax:
      "Wrapped AVAX"
    case .avax:
      "Avalanche"
    case .frnt:
      "Frontier Stable Token"
    default:
      nil
    }
  }
  
  public var index: Int {
    switch self {
    case .usd: return 0
    case .doge: return 1
    case .avax: return 2
    case .cardano: return 3
    case .usdc: return 4
    case .wavax: return 5
    case .usdt: return 6
    case .usdte: return 7
    case .frnt: return 8
    }
  }
  
  public var isCrypto: Bool {
    switch self {
    case .usd, .usdc, .usdt, .usdte:
      return false
    default:
      return true
    }
  }
  
  public var icon: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.icUsd.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .usdt, .usdte:
      return GenImages.CommonImages.icUsdt.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvax.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardano.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDoge.swiftUIImage
    case .wavax:
      return GenImages.CommonImages.icWavax.swiftUIImage
    case .frnt:
      return GenImages.CommonImages.icFrnt.swiftUIImage
    }
  }
  
  public var transactionIcon: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.icUsd.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .usdt, .usdte:
      return GenImages.CommonImages.icUsdt.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvax.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardano.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDoge.swiftUIImage
    case .wavax:
      return GenImages.CommonImages.icWavax.swiftUIImage
    case .frnt:
      return GenImages.CommonImages.icFrntBig.swiftUIImage
    }
  }
}
