import Foundation

public class NSCreateAccountPersonUseCase: NSCreateAccountPersonUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(personInfo: AccountPersonParametersEntity, sessionId: String) async throws -> AccountPersonDataEntity {
    try await repository.createAccountPerson(personInfo: personInfo, sessionId: sessionId)
  }
}
