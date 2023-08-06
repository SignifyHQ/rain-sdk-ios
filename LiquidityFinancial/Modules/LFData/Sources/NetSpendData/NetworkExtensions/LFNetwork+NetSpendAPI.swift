import LFNetwork
import Foundation
import LFUtilities

extension LFNetwork: NetSpendAPIProtocol where R == NetSpendRoute {
  public func sessionInit() async throws -> NetSpendJwkToken {
    return try await request(NetSpendRoute.sessionInit, target: NetSpendJwkToken.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func establishSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData {
    return try await request(NetSpendRoute.establishSession(deviceData), target: NetSpendSessionData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getAgreement() async throws -> NetSpendAgreementData {
    return try await request(NetSpendRoute.getAgreements, target: NetSpendAgreementData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> NetSpendAccountPersonData {
    return try await request(NetSpendRoute.createAccountPerson(personInfo, sessionId: sessionId), target: NetSpendAccountPersonData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getQuestion(sessionId: String) async throws -> NetSpendQuestionData {
    return try await request(NetSpendRoute.getQuestions(sessionId: sessionId), target: NetSpendQuestionData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func putQuestion(sessionId: String, encryptedData: String) async throws -> NetSpendAnswerQuestionData {
    return try await request(NetSpendRoute.putQuestions(sessionId: sessionId, encryptData: encryptedData), target: NetSpendAnswerQuestionData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getWorkflows() async throws -> NetSpendWorkflowsData {
    return try await request(NetSpendRoute.getWorkflows, target: NetSpendWorkflowsData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getDocuments(sessionId: String) async throws -> NetSpendDocumentData {
    return try await request(NetSpendRoute.getDocuments(sessionId: sessionId), target: NetSpendDocumentData.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> NetSpendDocumentData.RequestedDocument {
    return try await request(NetSpendRoute.uploadDocuments(path: path, documentData: documentData), target: NetSpendDocumentData.RequestedDocument.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getAuthorizationCode(sessionId: String) async throws -> NetSpendAuthorizationCode {
    return try await request(NetSpendRoute.getAuthorizationCode(sessionId: sessionId), target: NetSpendAuthorizationCode.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getLinkedSources(sessionID: String) async throws -> NetSpendLinkedSourcesResponse {
    try await request(
      NetSpendRoute.getLinkedSource(sessionId: sessionID),
      target: NetSpendLinkedSourcesResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func deleteLinkedSource(sessionId: String, sourceId: String) async throws -> NetspendUnlinkBankResponse {
    let result = try await request(NetSpendRoute.deleteLinkedSource(sessionId: sessionId, sourceId: sourceId))
    let statusCode = result.httpResponse?.statusCode
    return NetspendUnlinkBankResponse(success: statusCode == 200 || statusCode == 204)
  }
}
