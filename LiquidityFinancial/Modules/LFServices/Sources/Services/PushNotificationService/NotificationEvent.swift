import Foundation

public enum NotificationEvent {
  /// Payload type value that indicates a pending 3DS challenge (used to route the notification).
  public static let pending3DSChallengePayloadType = "3DS_APPROVAL"

  case transaction(id: String)
  case pending3DSChallenge(id: String, currency: String, amount: String, merchantCountry: String, merchantName: String, cardNumberLast4: String)
}
