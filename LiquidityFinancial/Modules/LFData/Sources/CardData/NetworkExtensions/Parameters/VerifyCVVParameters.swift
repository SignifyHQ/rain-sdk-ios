import Foundation
import CardDomain

public struct VerifyCVVParameters: VerifyCVVCodeParametersEntity {
  public let verificationType: String
  public let encryptedData: String
  
  public init(verificationType: String, encryptedData: String) {
    self.verificationType = verificationType
    self.encryptedData = encryptedData
  }
}
