import SolidDomain

public struct APISolidCard: Codable, SolidCardEntity {
  public var id: String
  public var name: String?
  public var expirationMonth: String
  public var expirationYear: String
  public var panLast4: String
  public var type: String
  public var cardStatus: String
  public var createdAt: String?
  public var isRoundUpDonationEnabled: Bool?
}
