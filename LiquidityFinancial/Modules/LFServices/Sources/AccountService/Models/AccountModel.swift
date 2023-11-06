import Foundation

public struct AccountModel {
  public let id: String
  public let externalAccountId: String?
  public let currency: CurrencyType
  public let availableBalance: Double
  public let availableUsdBalance: Double
  
  public init?(id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double) {
    guard let type = CurrencyType(rawValue: currency) else {
      return nil
    }
    self.id = id
    self.externalAccountId = externalAccountId
    self.currency = type
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
  }
}
