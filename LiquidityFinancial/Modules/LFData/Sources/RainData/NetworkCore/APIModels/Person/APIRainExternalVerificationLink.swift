import Foundation
import RainDomain

public struct APIRainExternalVerificationLink: Decodable {
  public let url: String
  public let params: APIRainParams?
  public var paramsEntity: RainParamsEntity? {
    params
  }
  
  public init(url: String, params: APIRainParams?) {
    self.url = url
    self.params = params
  }
}

public struct APIRainParams: Decodable, RainParamsEntity {
  public let userId: String?
}

extension APIRainExternalVerificationLink: RainExternalVerificationLinkEntity {}
