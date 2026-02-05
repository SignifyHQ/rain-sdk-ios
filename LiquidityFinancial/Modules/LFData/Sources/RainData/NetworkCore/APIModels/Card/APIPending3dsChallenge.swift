import RainDomain

public struct APIPending3dsChallenge: Decodable, Pending3dsChallengeEntity {
  public var id: String
  public var type: String?
  public var userId: String?
  public var cardId: String?
  public var status: String?
  public var rainUserId: String?
  public var rainCardId: String?
  public var rainCard: APIRainCard?
  public var amount: Double?
  public var currency: String?
  public var merchantName: String?
  public var merchantCountry: String?
  public var challengeId: String?
  public var challengeStartedAt: String?
  public var challengeExpiresAt: String?
  public var challengeTimeToLive: Int?
  public var challengeOtp: String?
  public var decisionAt: String?
  public var decisionSource: String?
  public var createdAt: String?
  public var updatedAt: String?
  
  public var rainCardEntity: RainCardEntity? {
    rainCard
  }
}
