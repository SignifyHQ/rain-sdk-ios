import Foundation
import LFUtilities

public struct AssetModel: Hashable {
  public let id: String?
  public let type: AssetType?
  public let availableBalance: Double
  public let availableUsdBalance: Double?
  public let externalAccountId: String?
  
  public init(id: String?, type: AssetType?, availableBalance: Double, availableUsdBalance: Double?, externalAccountId: String?) {
    self.id = id
    self.type = type
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
    self.externalAccountId = externalAccountId
  }
  
  public var availableBalanceFormatted: String {
    availableBalance.formattedAmount(
      prefix: type == .usd ? Constants.CurrencyUnit.usd.rawValue : nil,
      minFractionDigits: type == .usd
      ? Constants.FractionDigitsLimit.fiat.minFractionDigits
      : Constants.FractionDigitsLimit.crypto.minFractionDigits,
      maxFractionDigits: type == .usd
      ? Constants.FractionDigitsLimit.fiat.maxFractionDigits
      : Constants.FractionDigitsLimit.crypto.maxFractionDigits
    )
  }
  
  public var availableUsdBalanceFormatted: String? {
    guard type != .usd else {
      return nil
    }
    return availableUsdBalance?.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: Constants.FractionDigitsLimit.fiat.maxFractionDigits
    )
  }
}
