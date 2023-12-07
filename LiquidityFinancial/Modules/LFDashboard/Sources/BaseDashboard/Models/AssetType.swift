import SwiftUI
import LFStyleGuide
import LFUtilities

public enum AssetType: String {
  case usd = "USD"
  case usdc = "USDC"
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
    }
  }
  
  public var image: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.icUsd.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvax.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardano.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDoge.swiftUIImage
    }
  }
  
  public var filledImage: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.usdSymbol.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvaxFilled.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardanoFilled.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDogeFilled.swiftUIImage
    }
  }
  
  public var lineImage: Image? {
    switch self {
    case .usd:
      return GenImages.CommonImages.usdSymbol.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvaxFilled.swiftUIImage
    case .cardano:
      return GenImages.CommonImages.icCardanoFilled.swiftUIImage
    case .doge:
      return GenImages.CommonImages.icDogeLine.swiftUIImage
    }
  }
}
