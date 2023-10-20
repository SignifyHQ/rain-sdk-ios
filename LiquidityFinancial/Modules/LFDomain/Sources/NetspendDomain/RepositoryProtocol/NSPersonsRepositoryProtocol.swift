import Foundation

public protocol NSPersonsRepositoryProtocol {
  func clientSessionInit() async throws -> NSJwkTokenEntity
  func establishPersonSession(deviceData: EstablishSessionParametersEntity) async throws -> EstablishedSessionEntity
  func getAgreement() async throws -> AgreementDataEntity
  func createAccountPerson(personInfo: AccountPersonParametersEntity, sessionId: String) async throws -> AccountPersonDataEntity
  func getQuestion(sessionId: String) async throws -> QuestionDataEntiy
  func putQuestion(sessionId: String, encryptedData: String) async throws -> Bool
  func getWorkflows() async throws -> WorkflowsDataEntity
  func getDocuments(sessionId: String) async throws -> DocumentDataEntity
  func uploadDocuments(path: PathDocumentParametersEntity, documentData: any DocumentParametersEntity) async throws -> UploadRequestedDocumentEntity
  func getAuthorizationCode(sessionId: String) async throws -> AuthorizationCodeEntity
  func postAgreement(body: [String: Any]) async throws -> Bool
}
