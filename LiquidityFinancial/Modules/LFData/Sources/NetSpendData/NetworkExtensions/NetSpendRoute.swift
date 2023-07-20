import LFNetwork
import Foundation
import DataUtilities
import AuthorizationManager

public enum NetSpendRoute {
  case sessionInit
  case establishSession(EstablishSessionParameters)
  case getAgreements
  case createAccountPerson(AccountPersonParameters, sessionId: String)
  case getQuestions(sessionId: String)
  case putQuestions(sessionId: String, encryptData: String)
  case getWorkflows
  case getDocuments(sessionId: String)
  case postDocuments(sessionId: String, documentId: String)
}

extension NetSpendRoute: LFRoute {
  
  var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .sessionInit:
      return "/v1/netspend/sessions/init"
    case .getAgreements:
      return "/v1/netspend/persons/agreements"
    case .establishSession:
      return "/v1/netspend/sessions"
    case .createAccountPerson:
      return "/v1/netspend/accounts/account-person"
    case .getQuestions:
      return "/v1/netspend/persons/identity-questions"
    case .putQuestions:
      return "/v1/netspend/persons/identity-questions"
    case .getWorkflows:
      return "/v1/netspend/persons/workflows"
    case .getDocuments:
      return "/v1/netspend/persons/document-requests"
    case .postDocuments(_, documentId: let documentId):
      return "/v1/netspend/persons/document-requests/\(documentId)"
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": authorization,
      "productId": APIConstants.productID
    ]
    switch self {
    case .sessionInit, .getAgreements, .establishSession, .getWorkflows:
      return base
    case .createAccountPerson(_, let sessionID):
      base["netspendSessionId"] = sessionID
      return base
    case .getQuestions(let sessionID):
      base["netspendSessionId"] = sessionID
      return base
    case .putQuestions(let sessionID, _):
      base["netspendSessionId"] = sessionID
      return base
    case .getDocuments(sessionId: let sessionID):
      base["netspendSessionId"] = sessionID
      return base
    case .postDocuments(sessionId: let sessionID, _):
      base["netspendSessionId"] = sessionID
      return base
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .sessionInit, .getAgreements, .getQuestions, .getWorkflows, .getDocuments:
      return .GET
    case .establishSession, .createAccountPerson, .postDocuments:
      return .POST
    case .putQuestions:
      return .PUT
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .sessionInit, .getAgreements, .getQuestions, .getWorkflows, .getDocuments, .postDocuments:
      return nil
    case .establishSession(let parameters):
      return parameters.encoded()
    case .createAccountPerson(let parameters, _):
      return parameters.encoded()
    case .putQuestions(_, let encryptData):
      var parametersData: [String: Any] = [:]
      parametersData["encryptedData"] = encryptData
      return parametersData
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .sessionInit, .getAgreements, .getQuestions, .getWorkflows, .getDocuments, .postDocuments:
      return nil
    case .establishSession, .createAccountPerson, .putQuestions:
      return .json
    }
  }
  
}
