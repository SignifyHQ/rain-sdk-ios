import Foundation
import NetSpendDomain

public struct APISetPinRequest: SetPinRequestEntity {
  public let verifyId: String
  public let encryptedData: String
  
  public init(verifyId: String, encryptedData: String) {
    self.verifyId = verifyId
    self.encryptedData = encryptedData
  }
}
