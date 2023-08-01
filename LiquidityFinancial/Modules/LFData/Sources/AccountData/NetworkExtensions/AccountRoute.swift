import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum AccountRoute {
  case createZeroHashAccount
  case getUser(deviceId: String)
  case getAccount(currencyType: String)
}

extension AccountRoute: LFRoute {
  
  public var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .createZeroHashAccount:
      return "/v1/zerohash/accounts"
    case .getUser:
      return "/v1/user"
    case .getAccount:
      return "/v1/account/"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .createZeroHashAccount: return .POST
    case .getUser, .getAccount: return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": self.productID
    ]
    switch self {
    case .createZeroHashAccount:
      base["Accept"] = "application/json"
      base["Authorization"] = authorization
      return base
    case .getUser(let deviceId):
      base["Accept"] = "application/json"
      base["Authorization"] = authorization
      base["ld-device-id"] = deviceId
      return base
    case .getAccount:
      base["Accept"] = "application/json"
      base["Authorization"] = authorization
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .createZeroHashAccount:
      return nil
    case .getUser:
      return nil
    case .getAccount(let currencyType):
      return ["currencyType": currencyType]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .createZeroHashAccount, .getUser:
      return nil
    case .getAccount:
      return .url
    }
  }
  
}
