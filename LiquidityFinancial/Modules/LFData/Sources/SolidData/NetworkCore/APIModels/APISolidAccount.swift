import SolidDomain

public struct APISolidAccount: Codable, SolidAccountEntity {
  public var id: String
  public var externalAccountId: String?
  public var currency: String
  public var availableBalance: Double
  public var availableUsdBalance: Double
  
  public init(id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double) {
    self.id = id
    self.externalAccountId = externalAccountId
    self.currency = currency
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
  }
}
