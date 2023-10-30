import Foundation

public protocol NSCreateAccountPersonUseCaseProtocol {
  func execute(personInfo: AccountPersonParametersEntity, sessionId: String) async throws -> AccountPersonDataEntity
}
