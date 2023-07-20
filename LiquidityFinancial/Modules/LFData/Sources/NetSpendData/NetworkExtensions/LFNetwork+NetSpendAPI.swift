import LFNetwork
import Foundation

extension LFNetwork: NetSpendAPIProtocol where R == NetSpendRoute {
  public func sessionInit() async throws -> NetSpendJwkToken {
    return try await request(NetSpendRoute.sessionInit, target: NetSpendJwkToken.self, decoder: .apiDecoder)
  }
  
  public func establishSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData {
    return try await request(NetSpendRoute.establishSession(deviceData), target: NetSpendSessionData.self, decoder: .apiDecoder)
  }
  
  public func getAgreement() async throws -> NetSpendAgreementData {
    return try await request(NetSpendRoute.getAgreements, target: NetSpendAgreementData.self, decoder: .apiDecoder)
  }
  
  public func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> NetSpendAccountPersonData {
    return try await request(NetSpendRoute.createAccountPerson(personInfo, sessionId: sessionId), target: NetSpendAccountPersonData.self, decoder: .apiDecoder)
  }
  
  public func getQuestion(sessionId: String) async throws -> NetSpendQuestionData {
    return try await request(NetSpendRoute.getQuestions(sessionId: sessionId), target: NetSpendQuestionData.self, decoder: .apiDecoder)
  }
  
  public func putQuestion(sessionId: String, encryptedData: String) async throws -> NetSpendAnswerQuestionData {
    return try await request(NetSpendRoute.putQuestions(sessionId: sessionId), target: NetSpendAnswerQuestionData.self, decoder: .apiDecoder)
  }
}
