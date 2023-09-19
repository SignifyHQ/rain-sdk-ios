import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import Factory

public enum DeviceRoute {
  case register(deviceId: String, token: String)
  case deregister(deviceId: String, token: String)
}

extension DeviceRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .register:
      return "/v1/devices/notifications/register"
    case .deregister:
      return "/v1/devices/notifications/deregister"
    }
  }
  
  public var httpMethod: HttpMethod {
    .POST
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Accept": "application/json",
      "Authorization": self.needAuthorizationKey
    ]
    switch self {
    case .register(let deviceId, _), .deregister(let deviceId, _):
      base["ld-device-id"] = deviceId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .register(_, let token), .deregister(_, let token):
      return [
        "deviceToken": token
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .register, .deregister:
      return .json
    }
  }
  
}
