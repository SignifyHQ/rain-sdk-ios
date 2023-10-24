import SolidDomain

public struct APISolidAccount: Codable, SolidAccountEntity {
  public var id: String
  public var externalAccountId: String?
  public var currency: String
  public var availableBalance: Double
  public var availableUsdBalance: Double
}
