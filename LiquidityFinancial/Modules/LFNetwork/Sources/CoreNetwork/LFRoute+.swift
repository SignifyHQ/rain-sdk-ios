import Foundation
import NetworkUtilities
import LFUtilities

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
    switch enviroment {
    case .productionLive: return APIConstants.baseProdURL
    case .productionTest: return APIConstants.baseDevURL
    }
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
  }
  
  private var enviroment: NetworkEnvironment {
    NetworkEnvironment(rawValue: UserDefaults.environmentSelection) ?? .productionLive
  }
}
