import CoreNetwork
import Foundation
import LFUtilities

extension LFNetwork: NSPersonsAPIProtocol where R == NSPersonsRoute {
  public func sessionInit() async throws -> APINSJwkToken {
    return try await request(NSPersonsRoute.sessionInit, target: APINSJwkToken.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func establishSession(deviceData: EstablishSessionParameters) async throws -> APISessionData {
    return try await request(NSPersonsRoute.establishSession(deviceData), target: APISessionData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getAgreement() async throws -> APIAgreementData {
    return try await request(NSPersonsRoute.getAgreements, target: APIAgreementData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> APIAccountPersonData {
    return try await request(NSPersonsRoute.createAccountPerson(personInfo, sessionId: sessionId), target: APIAccountPersonData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getQuestion(sessionId: String) async throws -> APIQuestionData {
    return try await request(NSPersonsRoute.getQuestions(sessionId: sessionId), target: APIQuestionData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func putQuestion(sessionId: String, encryptedData: String) async throws -> APIAnswerQuestionData {
    return try await request(NSPersonsRoute.putQuestions(sessionId: sessionId, encryptData: encryptedData), target: APIAnswerQuestionData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getWorkflows() async throws -> APIWorkflowsData {
    return try await request(NSPersonsRoute.getWorkflows, target: APIWorkflowsData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getDocuments(sessionId: String) async throws -> APIDocumentData {
    return try await request(NSPersonsRoute.getDocuments(sessionId: sessionId), target: APIDocumentData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> APIDocumentData.RequestedDocument {
    return try await request(NSPersonsRoute.uploadDocuments(path: path, documentData: documentData), target: APIDocumentData.RequestedDocument.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getAuthorizationCode(sessionId: String) async throws -> APIAuthorizationCode {
    return try await request(NSPersonsRoute.getAuthorizationCode(sessionId: sessionId), target: APIAuthorizationCode.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func postAgreement(body: [String: Any]) async throws -> Bool {
    let result = try await request(NSPersonsRoute.postAgreements(body))
    return (result.httpResponse?.statusCode ?? 500).isSuccess
  }
}
