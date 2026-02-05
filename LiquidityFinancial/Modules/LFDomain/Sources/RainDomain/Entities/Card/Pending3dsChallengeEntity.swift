import Foundation

public protocol Pending3dsChallengeEntity {
  var id: String { get }
  var type: String? { get }
  var userId: String? { get }
  var cardId: String? { get }
  var status: String? { get }
  var rainUserId: String? { get }
  var rainCardId: String? { get }
  var rainCardEntity: RainCardEntity? { get }
  var amount: Double? { get }
  var currency: String? { get }
  var merchantName: String? { get }
  var merchantCountry: String? { get }
  var challengeId: String? { get }
  var challengeStartedAt: String? { get }
  var challengeExpiresAt: String? { get }
  var challengeTimeToLive: Int? { get }
  var challengeOtp: String? { get }
  var decisionAt: String? { get }
  var decisionSource: String? { get }
  var createdAt: String? { get }
  var updatedAt: String? { get }
}
