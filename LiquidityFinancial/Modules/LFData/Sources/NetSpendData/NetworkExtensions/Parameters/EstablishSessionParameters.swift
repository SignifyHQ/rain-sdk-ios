import Foundation
import DataUtilities

public struct EstablishSessionParameters: Parameterable {
  public let encryptedData: String
  
  public init(encryptedData: String) {
    self.encryptedData = encryptedData
  }
}
