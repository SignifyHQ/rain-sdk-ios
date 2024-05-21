import Foundation
import RainDomain

public struct APIRainWithdrawalSignature: Decodable, RainWithdrawalSignatureEntity {
  public let status: String
  public let retryAfterSeconds: Int?
  public let signature: APIRainSignature?
  public let expiresAt: String?
  
  public var signatureEntity: RainSignatureEntity? {
    signature
  }
}

public struct APIRainSignature: Decodable, RainSignatureEntity {
  public let data: String
  public let salt: String
}
