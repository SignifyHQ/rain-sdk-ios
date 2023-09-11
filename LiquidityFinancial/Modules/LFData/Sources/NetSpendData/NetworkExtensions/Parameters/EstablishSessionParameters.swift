import Foundation
import NetworkUtilities
import NetSpendDomain

public struct EstablishSessionParameters: Parameterable, EstablishSessionParametersEntity {
  public let encryptedData: String
  
  public init(encryptedData: String) {
    self.encryptedData = encryptedData
  }
}
