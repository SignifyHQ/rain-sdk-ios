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
  case uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters)
  case getAuthorizationCode(sessionId: String)
  case getLinkedSource(sessionId: String)
  case deleteLinkedSource(sessionId: String, sourceId: String)
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
    case .uploadDocuments(let path, _):
      return "/v1/netspend/persons/document-requests/\(path.documentID)"
    case .getAuthorizationCode:
      return "/v1/netspend/client-sdk/authorization-codes"
    case .getLinkedSource:
      return "/v1/netspend/external-funding"
    case .deleteLinkedSource(_, let sourceId):
      return "/v1/netspend/external-funding/external-card/\(sourceId)"
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": authorization,
      "productId": self.productID
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
    case .uploadDocuments(let path, _):
      base["netspendSessionId"] = path.sessionId
      return base
    case .getAuthorizationCode(let sessionID):
      base["netspendSessionId"] = sessionID
      return base
    case .getLinkedSource(let sessionId):
      base["netspendSessionId"] = sessionId
      return base
    case .deleteLinkedSource(let sessionId, _):
      base["netspendSessionId"] = sessionId
      return base
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .sessionInit, .getAgreements, .getQuestions, .getWorkflows, .getDocuments, .getLinkedSource:
      return .GET
    case .establishSession, .createAccountPerson, .getAuthorizationCode:
      return .POST
    case .putQuestions:
      return .PUT
    case .uploadDocuments(let path, _):
      return path.isUpdate ? .PUT : .POST
    case .deleteLinkedSource:
      return .DELETE
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .sessionInit, .getAgreements, .getQuestions, .getWorkflows, .getDocuments, .getAuthorizationCode, .getLinkedSource, .deleteLinkedSource:
      return nil
    case .establishSession(let parameters):
      return parameters.encoded()
    case .createAccountPerson(let parameters, _):
      return parameters.encoded()
    case .putQuestions(_, let encryptData):
      var parametersData: [String: Any] = [:]
      parametersData["encryptedData"] = encryptData
      return parametersData
    case .uploadDocuments(_, let documentData):
      return documentData.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .sessionInit, .getAgreements, .getQuestions, .getWorkflows, .getDocuments, .getAuthorizationCode, .getLinkedSource, .deleteLinkedSource:
      return nil
    case .establishSession, .createAccountPerson, .putQuestions, .uploadDocuments:
      return .json
    }
  }
  
}
