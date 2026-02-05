import Foundation
import RainDomain

public struct Pending3DSChallenge {
  public static func == (lhs: Pending3DSChallenge, rhs: Pending3DSChallenge) -> Bool {
    lhs.id == rhs.id
  }
  
  public let id: String
  public let type: String?
  public let userId: String?
  public let cardId: String?
  public let status: String?
  public let rainUserId: String?
  public let rainCardId: String?
  public let rainCard: RainCardEntity?
  public let amount: Double?
  public let currency: String?
  public let merchantName: String?
  public let merchantCountry: String?
  public let challengeId: String?
  public let challengeStartedAt: String?
  public let challengeExpiresAt: String?
  public let challengeTimeToLive: Int?
  public let challengeOtp: String?
  public let decisionAt: String?
  public let decisionSource: String?
  public let createdAt: String?
  public let updatedAt: String?
}

public extension Pending3DSChallenge {
  init(
    id: String,
    currency: String,
    amount: String,
    merchantCountry: String,
    merchantName: String
  ) {
    self.id = id
    self.type = nil
    self.userId = nil
    self.cardId = nil
    self.status = nil
    self.rainUserId = nil
    self.rainCardId = nil
    self.rainCard = nil
    self.amount = Double(amount)
    self.currency = currency
    self.merchantName = merchantName
    self.merchantCountry = merchantCountry
    self.challengeId = nil
    self.challengeStartedAt = nil
    self.challengeExpiresAt = nil
    self.challengeTimeToLive = nil
    self.challengeOtp = nil
    self.decisionAt = nil
    self.decisionSource = nil
    self.createdAt = nil
    self.updatedAt = nil
  }

  init(entity: Pending3dsChallengeEntity) {
    self.id = entity.id
    self.type = entity.type
    self.userId = entity.userId
    self.cardId = entity.cardId
    self.status = entity.status
    self.rainUserId = entity.rainUserId
    self.rainCardId = entity.rainCardId
    self.rainCard = entity.rainCardEntity
    self.amount = entity.amount
    self.currency = entity.currency
    self.merchantName = entity.merchantName
    self.merchantCountry = entity.merchantCountry
    self.challengeId = entity.challengeId
    self.challengeStartedAt = entity.challengeStartedAt
    self.challengeExpiresAt = entity.challengeExpiresAt
    self.challengeTimeToLive = entity.challengeTimeToLive
    self.challengeOtp = entity.challengeOtp
    self.decisionAt = entity.decisionAt
    self.decisionSource = entity.decisionSource
    self.createdAt = entity.createdAt
    self.updatedAt = entity.updatedAt
  }
}
