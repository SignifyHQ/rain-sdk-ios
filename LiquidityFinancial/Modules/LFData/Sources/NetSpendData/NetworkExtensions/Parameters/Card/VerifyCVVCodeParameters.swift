import Foundation
import DataUtilities
import NetSpendDomain

public struct VerifyCVVCodeParameters: Parameterable, VerifyCVVCodeParametersEntity {
  public let verificationType: String
  public let encryptedData: String
  
  public init(verificationType: String, encryptedData: String) {
    self.verificationType = verificationType
    self.encryptedData = encryptedData
  }
}
