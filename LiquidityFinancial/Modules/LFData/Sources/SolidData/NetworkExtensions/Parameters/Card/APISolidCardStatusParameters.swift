import Foundation
import SolidDomain
import NetworkUtilities

public struct APISolidCardStatusParameters: Parameterable, SolidCardStatusParametersEntity {
  public let cardStatus: String
  
  public init(cardStatus: String) {
    self.cardStatus = cardStatus
  }
}
