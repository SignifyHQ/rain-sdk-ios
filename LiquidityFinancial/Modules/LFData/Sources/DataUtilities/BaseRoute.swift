import Foundation
import LFNetwork

extension LFRoute {
  public var baseURL: URL {
    APIConstants.baseURL
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": APIConstants.productID
    ]
  }
}
