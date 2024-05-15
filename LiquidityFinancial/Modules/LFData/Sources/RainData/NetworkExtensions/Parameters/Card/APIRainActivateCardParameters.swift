import Foundation
import NetworkUtilities
import RainDomain

public struct APIRainActivateCardParameters: Parameterable, RainActivateCardParametersEntity {
  public var last4: String
  
  public init(last4: String) {
    self.last4 = last4
  }
}
