import Foundation
import NetworkUtilities

public struct SetPinParameters: Parameterable {
  public let verifyId: String
  public let encryptedData: String
}
