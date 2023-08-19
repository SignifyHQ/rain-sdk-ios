import Foundation
import CoreNetwork

public protocol NSPersonsAPIProtocol {
  func sessionInit() async throws -> APINSJwkToken
  func establishSession(deviceData: EstablishSessionParameters) async throws -> APISessionData
  func getAgreement() async throws -> APIAgreementData
  func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> APIAccountPersonData
  func getQuestion(sessionId: String) async throws -> APIQuestionData
  func putQuestion(sessionId: String, encryptedData: String) async throws -> APIAnswerQuestionData
  func getWorkflows() async throws -> APIWorkflowsData
  func getDocuments(sessionId: String) async throws -> APIDocumentData
  func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> APIDocumentData.RequestedDocument
  func getAuthorizationCode(sessionId: String) async throws -> APIAuthorizationCode
  func postAgreement(body: [String: Any]) async throws -> Bool
}
