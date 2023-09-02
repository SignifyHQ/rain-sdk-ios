import Foundation
import AccountDomain

public struct APIAccount: Decodable, LFAccount {
  public let id: String
  public let externalAccountId: String?
  public let currency: String
  public let availableBalance: Double
  public let availableUsdBalance: Double
  
  public init(id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double) {
    self.id = id
    self.externalAccountId = externalAccountId
    self.currency = currency
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
  }
}
