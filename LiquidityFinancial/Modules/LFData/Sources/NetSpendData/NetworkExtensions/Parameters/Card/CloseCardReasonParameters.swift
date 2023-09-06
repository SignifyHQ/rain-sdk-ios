import Foundation
import NetworkUtilities
import NetSpendDomain

public struct CloseCardReasonParameters: Parameterable, CloseCardReasonEntity {
  public let reason: String?
  
  public init(reason: String? = nil) {
    self.reason = reason
  }
}
