import Foundation
import SolidDomain
import NetworkUtilities

public struct APISolidCardNameParameters: Parameterable, SolidCardNameParametersEntity {
  public let name: String
  
  public init(name: String) {
    self.name = name
  }
}
