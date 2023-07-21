import SwiftUI
import LFStyleGuide
import LFUtilities

enum AssetType {
  case usd
  case usdc
  case avax
  
  var title: String {
    switch self {
    case .usd:
      return "USD"
    case .usdc:
      return "USDC"
    case .avax:
      return "AVAX"
    }
  }
  
  var image: Image {
    switch self {
    case .usd:
      return GenImages.CommonImages.icUsd.swiftUIImage
    case .usdc:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .avax:
      return GenImages.CommonImages.icAvax.swiftUIImage
    }
  }
  
  func getBalance(balance: Double) -> (String, String?) {
    let usdBalance = balance.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2)
    switch self {
    case .usd:
      return (usdBalance, nil)
    case .avax:
        // logic convert from usd to avax
      return ("242.322", usdBalance) // HARDCODE for UI
    case .usdc:
        // logic convert from usd to usdc
      return ("42.322", usdBalance) // HARDCODE for UI
    }
  }
}
