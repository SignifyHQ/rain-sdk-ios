import Foundation

public class NSPersonsUseCase: NSPersonsUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func clientSessionInit() async throws -> NSJwkTokenEntity {
    try await repository.clientSessionInit()
  }
  
  public func establishPersonSession(deviceData: EstablishSessionParametersEntity) async throws -> EstablishedSessionEntity {
    try await repository.establishPersonSession(deviceData: deviceData)
  }
  
  public func getAgreement() async throws -> AgreementDataEntity {
    try await repository.getAgreement()
  }
  
  public func createAccountPerson(personInfo: AccountPersonParametersEntity, sessionId: String) async throws -> AccountPersonDataEntity {
    try await repository.createAccountPerson(personInfo: personInfo, sessionId: sessionId)
  }
  
  public func getQuestion(sessionId: String) async throws -> QuestionDataEntiy {
    try await repository.getQuestion(sessionId: sessionId)
  }
  
  public func putQuestion(sessionId: String, encryptedData: String) async throws -> Bool {
    try await repository.putQuestion(sessionId: sessionId, encryptedData: encryptedData)
  }
  
  public func getWorkflows() async throws -> WorkflowsDataEntity {
    try await repository.getWorkflows()
  }
  
  public func getDocuments(sessionId: String) async throws -> DocumentDataEntity {
    try await repository.getDocuments(sessionId: sessionId)
  }
  
  public func uploadDocuments(path: PathDocumentParametersEntity, documentData: any DocumentParametersEntity) async throws -> UploadRequestedDocumentEntity {
    try await repository.uploadDocuments(path: path, documentData: documentData)
  }
  
  public func getAuthorizationCode(sessionId: String) async throws -> AuthorizationCodeEntity {
    try await repository.getAuthorizationCode(sessionId: sessionId)
  }
  
  public func postAgreement(body: [String: Any]) async throws -> Bool {
    try await repository.postAgreement(body: body)
  }
}
