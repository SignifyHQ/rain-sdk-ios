import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum SolidAccountRoute {
  case getAccounts
  case getAccountDetail(id: String)
  case getAccountLimits
  case getStatementItem(liquidityAccountId: String, year: String, month: String)
  case getAllStatement(liquidityAccountId: String)
}

extension SolidAccountRoute: LFRoute {

  public var path: String {
    switch self {
    case .getAccounts:
      return "/v1/solid/accounts"
    case .getAccountDetail(let id):
      return "/v1/solid/accounts/\(id)"
    case .getAccountLimits:
      return "/v1/solid/accounts/limits"
    case let .getAllStatement(liquidityAccountId):
      return "/v1/solid/accounts/\(liquidityAccountId)/statements"
    case let .getStatementItem(liquidityAccountId, year, month):
      return "/v1/solid/accounts/\(liquidityAccountId)/statement/\(year)/\(month)"
    }
  }
  
  public var httpMethod: HttpMethod {
    .GET
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey,
      "ld-device-id": LFUtilities.deviceId
    ]
    switch self {
    case .getAccounts, .getAccountDetail, .getAccountLimits, .getAllStatement:
      base["Content-Type"] = "application/json"
      base["Accept"] = "application/json"
    case .getStatementItem:
      base["Content-Type"] = "application/pdf"
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .getAccounts, .getAccountDetail, .getAccountLimits, .getAllStatement:
      return nil
    case .getStatementItem:
      return ["export": "pdf"]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getAccounts, .getAccountDetail, .getAccountLimits, .getAllStatement:
      return nil
    case .getStatementItem:
      return .url
    }
  }
  
}
