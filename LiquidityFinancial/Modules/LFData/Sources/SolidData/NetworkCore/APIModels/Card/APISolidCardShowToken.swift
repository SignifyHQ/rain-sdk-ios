import SolidDomain

public struct APISolidCardShowToken: Codable, SolidCardShowTokenEntity {
  public var solidCardId: String
  public var showToken: String
}
