import Foundation
import NetworkUtilities

extension LFRoute {
  public var scheme: String {
    "https"
  }
  
  public var url: URL {
    guard !path.isEmpty else {
      return baseURL
    }
    return baseURL.appendingPathComponent(path)
  }
  
  public var needAuthorizationKey: String {
    "need_authorization"
  }
  
  public var baseURL: URL {
    APIConstants.baseDevURL
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
  }
}
