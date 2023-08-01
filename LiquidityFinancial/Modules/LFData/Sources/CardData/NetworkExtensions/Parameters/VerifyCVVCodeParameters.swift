import Foundation
import DataUtilities

public struct VerifyCVVCodeParameters: Parameterable {
  public let verificationType: String
  public let encryptedData: String
}
