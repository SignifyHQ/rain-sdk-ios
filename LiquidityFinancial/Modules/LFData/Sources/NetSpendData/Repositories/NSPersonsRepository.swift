import Foundation
import CoreNetwork
import LFServices
import NetspendSdk
import FraudForce
import LFUtilities
import BankDomain

public class NSPersonsRepository: NSPersonsRepositoryProtocol {
  
  private let netSpendAPI: NSPersonsAPIProtocol
  
  public init(netSpendAPI: NSPersonsAPIProtocol) {
    self.netSpendAPI = netSpendAPI
  }
  
  public func clientSessionInit() async throws -> NSJwkTokenEntity {
    return try await netSpendAPI.sessionInit()
  }
  
  public func establishingSessionWithJWKSet(jwtToken: NSJwkTokenEntity) async -> NetspendSdkUserSessionConnectionJWKSet! {
    var session: NetspendSdkUserSessionConnectionJWKSet!
    do {
      session = try NetspendSdk.shared.createUserSessionConnection(jwkSet: jwtToken.rawData, iovationToken: FraudForce.blackbox())
      try await Task.sleep(seconds: 0.5) // We need to wait for sdk make sure the init session
    } catch {
      log.error(error)
    }
    return session
  }
  
  public func establishPersonSession(deviceData: EstablishSessionParametersEntity) async throws -> EstablishedSessionEntity {
    if let deviceData = deviceData as? EstablishSessionParameters {
      return try await netSpendAPI.establishSession(deviceData: deviceData)
    } else {
      throw "Can't map paramater establishPersonSession:\(deviceData)"
    }
  }
  
  public func getAgreement() async throws -> AgreementDataEntity {
    return try await netSpendAPI.getAgreement()
  }
  
  public func createUserSession(establishingSession: NetspendSdkUserSessionConnectionJWKSet?, encryptedData: String) throws -> NetspendSdkUserSession? {
    return try establishingSession?.createUserSession(userSessionEncryptedData: encryptedData)
  }
  
  public func createAccountPerson(personInfo: AccountPersonParametersEntity, sessionId: String) async throws -> AccountPersonDataEntity {
    if let personInfo = personInfo as? AccountPersonParameters {
      return try await netSpendAPI.createAccountPerson(personInfo: personInfo, sessionId: sessionId)
    } else {
      throw "Can't map paramater personInfo:\(personInfo)"
    }
  }
  
  public func getQuestion(sessionId: String) async throws -> QuestionDataEntiy {
    return try await netSpendAPI.getQuestion(sessionId: sessionId)
  }
  
  public func putQuestion(sessionId: String, encryptedData: String) async throws -> Bool {
    return try await netSpendAPI.putQuestion(sessionId: sessionId, encryptedData: encryptedData)
  }
  
  public func getWorkflows() async throws -> WorkflowsDataEntity {
    return try await netSpendAPI.getWorkflows()
  }
  
  public func getDocuments(sessionId: String) async throws -> DocumentDataEntity {
    return try await netSpendAPI.getDocuments(sessionId: sessionId)
  }
  
  public func uploadDocuments(path: PathDocumentParametersEntity, documentData: any DocumentParametersEntity) async throws -> UploadRequestedDocumentEntity {
    if let path = path as? PathDocumentParameters, let documentData = documentData as? DocumentParameters {
      return try await netSpendAPI.uploadDocuments(path: path, documentData: documentData)
    } else {
      throw "Can't map paramater uploadDocuments:\(path) and \(documentData)"
    }
  }
  
  public func getAuthorizationCode(sessionId: String) async throws -> AuthorizationCodeEntity {
    return try await netSpendAPI.getAuthorizationCode(sessionId: sessionId)
  }
  
  public func postAgreement(body: [String: Any]) async throws -> Bool {
    return try await netSpendAPI.postAgreement(body: body)
  }
  
  public func getSession(sessionId: String) async throws -> APISessionData {
    return try await netSpendAPI.getSession(sessionId: sessionId)
  }
}
