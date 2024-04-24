import Foundation
import LFUtilities
import AccountService
import Services

public struct AssetModel: Hashable {
  public let id: String
  public let type: AssetType?
  public let availableBalance: Double
  public let availableUsdBalance: Double?
  public let externalAccountId: String?
  
  public init(id: String, type: AssetType?, availableBalance: Double, availableUsdBalance: Double?, externalAccountId: String?) {
    self.id = id
    self.type = type
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
    self.externalAccountId = externalAccountId
  }
  
  public init(account: AccountModel) {
    self.id = account.id
    self.type = AssetType(rawValue: account.currency.rawValue.uppercased())
    self.availableBalance = account.availableBalance
    self.availableUsdBalance = account.availableUsdBalance
    self.externalAccountId = account.externalAccountId
  }
  
  public init(portalBalance: PortalBalance) {
    self.id = portalBalance.token.contractAddress
    self.type = AssetType(rawValue: portalBalance.token.symbol.uppercased())
    self.availableBalance = portalBalance.balance
    // TODO(Volo): Need to figure out how to get the USD prices and balances
    self.availableUsdBalance = nil
    self.externalAccountId = nil
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
