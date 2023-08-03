import Foundation
import LFServices
import NetspendSdk
import FraudForce
import LFUtilities

public protocol NetSpendRepositoryProtocol {
  func clientSessionInit() async throws -> NetSpendJwkToken
  func establishingSessionWithJWKSet(jwtToken: NetSpendJwkToken) async -> NetspendSdkUserSessionConnectionJWKSet!
  func establishPersonSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData
  func createUserSession(establishingSession: NetspendSdkUserSessionConnectionJWKSet?, encryptedData: String) throws -> NetspendSdkUserSession?
  func getAgreement() async throws -> NetSpendAgreementData
  func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> NetSpendAccountPersonData
  func getQuestion(sessionId: String) async throws -> NetSpendQuestionData
  func putQuestion(sessionId: String, encryptedData: String) async throws -> NetSpendAnswerQuestionData
  func getWorkflows() async throws -> NetSpendWorkflowsData
  func getDocuments(sessionId: String) async throws -> NetSpendDocumentData
  func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> NetSpendDocumentData.RequestedDocument
  func getAuthorizationCode(sessionId: String) async throws -> NetSpendAuthorizationCode
}

public class NetSpendRepository: NetSpendRepositoryProtocol {
  
  private let netSpendAPI: NetSpendAPIProtocol
  
  public init(netSpendAPI: NetSpendAPIProtocol) {
    self.netSpendAPI = netSpendAPI
  }
  
  public func clientSessionInit() async throws -> NetSpendJwkToken {
    return try await netSpendAPI.sessionInit()
  }
  
  public func establishingSessionWithJWKSet(jwtToken: NetSpendJwkToken) async -> NetspendSdkUserSessionConnectionJWKSet! {
    var session: NetspendSdkUserSessionConnectionJWKSet!
    do {
      session = try NetspendSdk.shared.createUserSessionConnection(jwkSet: jwtToken.rawData, iovationToken: FraudForce.blackbox())
      try await Task.sleep(seconds: 1) // We need to wait for sdk make sure the init session
    } catch {
      log.error(error)
    }
    return session
  }
  
  public func establishPersonSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData {
    return try await netSpendAPI.establishSession(deviceData: deviceData)
  }
  
  public func getAgreement() async throws -> NetSpendAgreementData {
    return try await netSpendAPI.getAgreement()
  }
  
  public func createUserSession(establishingSession: NetspendSdkUserSessionConnectionJWKSet?, encryptedData: String) throws -> NetspendSdkUserSession? {
    return try establishingSession?.createUserSession(userSessionEncryptedData: encryptedData)
  }
  
  public func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> NetSpendAccountPersonData {
    return try await netSpendAPI.createAccountPerson(personInfo: personInfo, sessionId: sessionId)
  }
  
  public func getQuestion(sessionId: String) async throws -> NetSpendQuestionData {
    return try await netSpendAPI.getQuestion(sessionId: sessionId)
  }
  
  public func putQuestion(sessionId: String, encryptedData: String) async throws -> NetSpendAnswerQuestionData {
    return try await netSpendAPI.putQuestion(sessionId: sessionId, encryptedData: encryptedData)
  }
  
  public func getWorkflows() async throws -> NetSpendWorkflowsData {
    return try await netSpendAPI.getWorkflows()
  }
  
  public func getDocuments(sessionId: String) async throws -> NetSpendDocumentData {
    return try await netSpendAPI.getDocuments(sessionId: sessionId)
  }
  
  public func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> NetSpendDocumentData.RequestedDocument {
    return try await netSpendAPI.uploadDocuments(path: path, documentData: documentData)
  }
  
  public func getAuthorizationCode(sessionId: String) async throws -> NetSpendAuthorizationCode {
    return try await netSpendAPI.getAuthorizationCode(sessionId: sessionId)
  }
}
