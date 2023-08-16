import Foundation
import NetworkUtilities

public extension LFRoute {
  var baseURL: URL {
    APIConstants.baseDevURL
  }
  
  var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
  }
}
