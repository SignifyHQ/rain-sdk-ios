import Foundation
import LFUtilities
import AccountService
import Services
import RainDomain

public struct AssetModel: Hashable, Identifiable {
  public let id: String
  public let type: AssetType?
  
  public let availableBalance: Double
  public let availableUsdBalance: Double?
  public let exchangeRate: Double?
  public let advanceRate: Double?
  
  public let externalAccountId: String?
  
  public init(
    id: String,
    type: AssetType?,
    availableBalance: Double,
    availableUsdBalance: Double?,
    externalAccountId: String?
  ) {
    self.id = id
    self.type = type
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
    self.externalAccountId = externalAccountId
    
    self.exchangeRate = nil
    self.advanceRate = nil
  }
  
  public init(
    account: AccountModel
  ) {
    self.id = account.id
    self.type = AssetType(rawValue: account.currency.rawValue.uppercased())
    self.availableBalance = account.availableBalance
    self.availableUsdBalance = account.availableUsdBalance
    self.externalAccountId = account.externalAccountId
    
    self.exchangeRate = nil
    self.advanceRate = nil
  }
  
  public init(
    portalAsset: PortalAsset
  ) {
    self.id = portalAsset.token.contractAddress
    self.type = AssetType(rawValue: portalAsset.token.symbol.uppercased())
    self.availableBalance = portalAsset.balance ?? 0
    self.externalAccountId = portalAsset.walletAddress
    
    self.availableUsdBalance = nil
    self.exchangeRate = nil
    self.advanceRate = nil
  }
  
  public init(
    rainCollateralAsset: RainTokenEntity
  ) {
    self.id = rainCollateralAsset.address
    self.type = AssetType(rawValue: rainCollateralAsset.symbol?.uppercased() ?? "")
    self.availableBalance = Double(rainCollateralAsset.balance)
    self.availableUsdBalance = rainCollateralAsset.availableUsdBalance
    self.exchangeRate = rainCollateralAsset.exchangeRate
    self.advanceRate = rainCollateralAsset.advanceRate
    
    self.externalAccountId = nil
  }
  
  public var conversionFactor: Int {
    switch type {
    case .usdc, .usdt, .usdte:
      6
    case .avax, .cardano, .doge, .wavax, .wyst:
      18
    default:
      2
    }
  }
  
  public var hasExchangeRate: Bool {
    (exchangeRate ?? 1) != 1
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
  
  public var exchangeRateFormatted: String {
    "x\(exchangeRate?.formattedUSDAmount() ?? "N/A")"
  }
  
  public var advanceRateFormatted: String {
    guard let advanceRate
    else {
      return "N/A"
    }
    
    return "x\(advanceRate.formattedAmount())%"
  }
}
