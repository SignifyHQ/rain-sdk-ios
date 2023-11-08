import SolidDomain

public struct APISolidCardPinToken: Codable, SolidCardPinTokenEntity {
  public var solidCardId: String
  public var pinToken: String
}
