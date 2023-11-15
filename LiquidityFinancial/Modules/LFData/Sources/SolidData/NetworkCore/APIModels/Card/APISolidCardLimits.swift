import Foundation
import SolidDomain

public struct APISolidCardLimits: Decodable, SolidCardLimitsEntity {
  public let solidCardId: String
  public let limitAmount: Int?
  public let limitInterval: String?
  public let availableLimit: Int?
  public let platformPerTransactionLimit: Int?
}
