import Foundation

public protocol NetSpendAPIProtocol {
  func sessionInit() async throws -> NetSpendJwkToken
  func establishSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData
  func getAgreement() async throws -> NetSpendAgreementData
  func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> NetSpendAccountPersonData
  func getQuestion(sessionId: String) async throws -> NetSpendQuestionData
  func putQuestion(sessionId: String, encryptedData: String) async throws -> NetSpendAnswerQuestionData
  func getWorkflows() async throws -> NetSpendWorkflowsData
  func getDocuments(sessionId: String) async throws -> NetSpendDocumentData
  func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> NetSpendDocumentData.RequestedDocument
  func getAuthorizationCode(sessionId: String) async throws -> NetSpendAuthorizationCode
  func getLinkedSources(sessionID: String) async throws -> NetSpendLinkedSourcesResponse
}
