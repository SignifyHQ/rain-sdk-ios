import Foundation
import NetworkUtilities
import NetspendDomain

public struct CloseCardReasonParameters: Parameterable, CloseCardReasonEntity {
  public let reason: String?
  
  public init(reason: String? = nil) {
    self.reason = reason
  }
}
