import Foundation
import LFUtilities

struct AssetModel: Hashable {
  let type: AssetType?
  let availableBalance: Double
  let availableUsdBalance: Double?
  
  var availableBalanceFormatted: String {
    availableBalance.formattedAmount(
      prefix: type == .usd ? Constants.CurrencyUnit.usd.rawValue : nil,
      minFractionDigits: 3,
      maxFractionDigits: 3
    )
  }
  
  var availableUsdBalanceFormatted: String? {
    guard type != .usd else {
      return nil
    }
    return availableUsdBalance?.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: 3,
      maxFractionDigits: 3
    )
  }
}
