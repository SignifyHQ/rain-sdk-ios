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
    self.exchangeRate = rainCollateralAsset.exchangeRate.rounded(to: 2)
    self.advanceRate = rainCollateralAsset.advanceRate
    
    self.externalAccountId = nil
  }
  
  public var conversionFactor: Int {
    switch type {
    case .usdc, .usdt, .usdte, .frnt:
      6
    case .avax, .cardano, .doge, .wavax:
      18
    default:
      2
    }
  }
  
  public var hasExchangeRate: Bool {
    (exchangeRate ?? 1) != 1
  }
  
  public var hasAdvanceRate: Bool {
    (advanceRate ?? 100) != 100
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
  
  public var totalUsdBalanceFormatted: String? {
    if type == .usd {
      return availableUsdBalance?.formattedAmount(
        prefix: Constants.CurrencyUnit.usd.rawValue,
        minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits,
        maxFractionDigits: Constants.FractionDigitsLimit.fiat.maxFractionDigits
      )
    } else {
      let cryptoUsdValue: Double = availableBalance * (exchangeRate ?? 1)
      
      return cryptoUsdValue.formattedAmount(
        prefix: Constants.CurrencyUnit.usd.rawValue,
        minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits,
        maxFractionDigits: Constants.FractionDigitsLimit.fiat.maxFractionDigits
      )
    }
  }
  
  public var availableToSpendUsdBalanceFormatted: String? {
    if type == .usd {
      return totalUsdBalanceFormatted
    } else {
      let cryptoUsdValue: Double = availableBalance * (exchangeRate ?? 1) * (advanceRate ?? 100) / 100
      
      return cryptoUsdValue.formattedAmount(
        prefix: Constants.CurrencyUnit.usd.rawValue,
        minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits,
        maxFractionDigits: Constants.FractionDigitsLimit.fiat.maxFractionDigits
      )
    }
  }
  
  public var isAvailableBalanceRoundedZero: Bool {
    if type == .usd {
      return availableBalance.rounded(to: Constants.FractionDigitsLimit.fiat.maxFractionDigits).isZero
    } else {
      return availableBalance.rounded(to: Constants.FractionDigitsLimit.crypto.maxFractionDigits).isZero
    }
  }
  
  public var exchangeRateFormatted: String {
    "\(exchangeRate?.formattedUSDAmount() ?? "N/A")"
  }
  
  public var advanceRateFormatted: String {
    guard let advanceRate
    else {
      return "N/A"
    }
    
    return "\(advanceRate.formattedAmount())%"
  }
}
