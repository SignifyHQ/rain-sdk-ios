import SwiftUI
import LFStyleGuide
import LFUtilities

enum AssetType: String {
  case usd = "USD"
  case usdc = "USDC"
  case avax = "AVAX"
  
  var title: String {
    self.rawValue
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
