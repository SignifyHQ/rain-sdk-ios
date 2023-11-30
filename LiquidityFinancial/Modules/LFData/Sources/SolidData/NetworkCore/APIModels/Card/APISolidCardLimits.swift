import Foundation
import SolidDomain

public struct APISolidCardLimits: Decodable, SolidCardLimitsEntity {
  public let solidCardId: String
  public let limitAmount: Double?
  public let limitInterval: String?
  public let availableLimit: Double?
  public let platformPerTransactionLimit: Double?
}
