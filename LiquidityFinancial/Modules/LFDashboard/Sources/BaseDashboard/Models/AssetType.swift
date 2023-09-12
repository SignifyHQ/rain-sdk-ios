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
}
