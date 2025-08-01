import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum MeshRoute {
  case getLinkToken
  case getLinkTokenFor(methodId: String)
  case getConnectedMethods
  case saveConnectedMethod(request: MeshConnection)
  case deleteConnectedMethod(methodId: String)
}

extension MeshRoute: LFRoute {
  public var path: String {
    switch self {
    case .getLinkToken:
      "/v1/mesh/link-token"
    case .getLinkTokenFor(let methodId):
      "/v1/mesh/methods/\(methodId)/transfer"
    case .getConnectedMethods:
      "/v1/mesh/methods"
    case .saveConnectedMethod(request: let request):
      "/v1/mesh/methods/connection"
    case .deleteConnectedMethod(let methodId):
      "/v1/mesh/methods/\(methodId)/remove"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .saveConnectedMethod, .deleteConnectedMethod:
        .POST
    default:
        .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "ld-device-id": LFUtilities.deviceId
    ]
    
    base["Authorization"] = self.needAuthorizationKey
    
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .saveConnectedMethod(let request):
      request.encoded()
    default:
      nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .saveConnectedMethod:
        .json
    default:
      nil
    }
  }
}
