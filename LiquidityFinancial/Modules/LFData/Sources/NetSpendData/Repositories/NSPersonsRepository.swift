import Foundation
import LFNetwork
import LFServices
import NetspendSdk
import FraudForce
import LFUtilities

public protocol NSPersonsRepositoryProtocol {
  func clientSessionInit() async throws -> APINSJwkToken
  func establishingSessionWithJWKSet(jwtToken: APINSJwkToken) async -> NetspendSdkUserSessionConnectionJWKSet!
  func establishPersonSession(deviceData: EstablishSessionParameters) async throws -> APISessionData
  func createUserSession(establishingSession: NetspendSdkUserSessionConnectionJWKSet?, encryptedData: String) throws -> NetspendSdkUserSession?
  func getAgreement() async throws -> APIAgreementData
  func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> APIAccountPersonData
  func getQuestion(sessionId: String) async throws -> APIQuestionData
  func putQuestion(sessionId: String, encryptedData: String) async throws -> APIAnswerQuestionData
  func getWorkflows() async throws -> APIWorkflowsData
  func getDocuments(sessionId: String) async throws -> APIDocumentData
  func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> APIDocumentData.RequestedDocument
  func getAuthorizationCode(sessionId: String) async throws -> APIAuthorizationCode
}

public class NSPersonsRepository: NSPersonsRepositoryProtocol {
  
  private let netSpendAPI: NSPersonsAPIProtocol
  
  public init(netSpendAPI: NSPersonsAPIProtocol) {
    self.netSpendAPI = netSpendAPI
  }
  
  public func clientSessionInit() async throws -> APINSJwkToken {
    return try await netSpendAPI.sessionInit()
  }
  
  public func establishingSessionWithJWKSet(jwtToken: APINSJwkToken) async -> NetspendSdkUserSessionConnectionJWKSet! {
    var session: NetspendSdkUserSessionConnectionJWKSet!
    do {
      session = try NetspendSdk.shared.createUserSessionConnection(jwkSet: jwtToken.rawData, iovationToken: FraudForce.blackbox())
      try await Task.sleep(seconds: 1) // We need to wait for sdk make sure the init session
    } catch {
      log.error(error)
    }
    return session
  }
  
  public func establishPersonSession(deviceData: EstablishSessionParameters) async throws -> APISessionData {
    return try await netSpendAPI.establishSession(deviceData: deviceData)
  }
  
  public func getAgreement() async throws -> APIAgreementData {
    return try await netSpendAPI.getAgreement()
  }
  
  public func createUserSession(establishingSession: NetspendSdkUserSessionConnectionJWKSet?, encryptedData: String) throws -> NetspendSdkUserSession? {
    return try establishingSession?.createUserSession(userSessionEncryptedData: encryptedData)
  }
  
  public func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> APIAccountPersonData {
    return try await netSpendAPI.createAccountPerson(personInfo: personInfo, sessionId: sessionId)
  }
  
  public func getQuestion(sessionId: String) async throws -> APIQuestionData {
    return try await netSpendAPI.getQuestion(sessionId: sessionId)
  }
  
  public func putQuestion(sessionId: String, encryptedData: String) async throws -> APIAnswerQuestionData {
    return try await netSpendAPI.putQuestion(sessionId: sessionId, encryptedData: encryptedData)
  }
  
  public func getWorkflows() async throws -> APIWorkflowsData {
    return try await netSpendAPI.getWorkflows()
  }
  
  public func getDocuments(sessionId: String) async throws -> APIDocumentData {
    return try await netSpendAPI.getDocuments(sessionId: sessionId)
  }
  
  public func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> APIDocumentData.RequestedDocument {
    return try await netSpendAPI.uploadDocuments(path: path, documentData: documentData)
  }
  
  public func getAuthorizationCode(sessionId: String) async throws -> APIAuthorizationCode {
    return try await netSpendAPI.getAuthorizationCode(sessionId: sessionId)
  }
}
