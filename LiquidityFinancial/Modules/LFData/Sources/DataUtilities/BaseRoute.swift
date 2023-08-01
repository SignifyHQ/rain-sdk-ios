import Foundation
import LFNetwork

extension LFRoute {
  public var baseURL: URL {
    APIConstants.baseURL
  }
  
  public var productID: String {
    DataUtilities.target == .Avalanche ? APIConstants.avalencheID : APIConstants.cardanoID
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": productID
    ]
  }
}
