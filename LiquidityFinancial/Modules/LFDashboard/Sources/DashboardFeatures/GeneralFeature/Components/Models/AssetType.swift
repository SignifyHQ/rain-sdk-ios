import SwiftUI
import LFStyleGuide
import LFUtilities

public enum AssetType: String {
  case usd = "USD"
  case usdc = "USDC"
  case usdt = "USDT"
  case wavax = "WAVAX"
  case avax = "AVAX"
  case cardano = "ADA"
  case doge = "DOGE"
  
  public var title: String {
    rawValue
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
    }
  }
  
  public var isCrypto: Bool {
    switch self {
    case .usd, .usdc, .usdt:
      return false
    default:
      return true
    }
  }
  
  public var image: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.icUsd.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .usdt:
      return GenImages.CommonImages.icUsdt.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvax.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardano.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDoge.swiftUIImage
    case .wavax:
      return GenImages.CommonImages.icWavax.swiftUIImage
    }
  }
  
  public var filledImage: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.usdSymbol.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .usdt:
      return GenImages.CommonImages.icUsdt.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvaxFilled.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardanoFilled.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDogeFilled.swiftUIImage
    case .wavax:
      return GenImages.CommonImages.icWavaxFilled.swiftUIImage
    }
  }
  
  public var lineImage: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.usdSymbol.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .usdt:
      return GenImages.CommonImages.icUsdt.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvaxFilled.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardanoFilled.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDogeLine.swiftUIImage
    case .wavax:
      return GenImages.CommonImages.icWavaxFilled.swiftUIImage
    }
  }
}
