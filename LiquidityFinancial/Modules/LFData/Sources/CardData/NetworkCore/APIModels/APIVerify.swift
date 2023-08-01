import Foundation
import CardDomain

public struct APIVerifyCVVResponse: VerifyCVVCodeResponseEntity {
  public let id: String
}

public struct APIVerifyCVVRequest: VerifyCVVCodeRequestEntity {
  public let verificationType: String
  public let encryptedData: String
  
  public init(verificationType: String, encryptedData: String) {
    self.verificationType = verificationType
    self.encryptedData = encryptedData
  }
}
