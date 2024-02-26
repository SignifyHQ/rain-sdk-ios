import Foundation
import SolidDomain
import NetworkUtilities

public struct APISolidCreateVirtualCardParameters: Parameterable, SolidCreateVirtualCardParametersEntity {
  public let name: String?
  
  public init(name: String?) {
    self.name = name
  }
}
