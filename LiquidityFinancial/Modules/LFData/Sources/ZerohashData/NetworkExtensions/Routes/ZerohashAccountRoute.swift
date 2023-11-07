import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum ZerohashAccountRoute {
  case getAccounts
  case getAccountDetail(id: String)
}

extension ZerohashAccountRoute: LFRoute {

  public var path: String {
    switch self {
    case .getAccounts:
      return "/v1/zerohash/accounts"
    case .getAccountDetail(let id):
      return "/v1/zerohash/accounts/\(id)"
    }
  }
  
  public var httpMethod: HttpMethod {
    .GET
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey,
      "Accept": "application/json",
      "ld-device-id": LFUtilities.deviceId
    ]
  }
  
  public var parameters: Parameters? {
    nil
  }
  
  public var parameterEncoding: ParameterEncoding? {
    .json
  }
  
}
