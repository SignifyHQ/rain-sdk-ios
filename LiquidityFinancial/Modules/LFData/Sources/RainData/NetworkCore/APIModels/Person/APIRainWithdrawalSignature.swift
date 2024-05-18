import Foundation
import RainDomain

public struct APIRainWithdrawalSignature: Decodable, RainWithdrawalSignatureEntity {
  public let data: String
  public let salt: String
  public let expiryAt: String
}
