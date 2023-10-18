import Foundation
import NetworkUtilities
import BankDomain

public struct EstablishSessionParameters: Parameterable, EstablishSessionParametersEntity {
  public let encryptedData: String
  
  public init(encryptedData: String) {
    self.encryptedData = encryptedData
  }
}
