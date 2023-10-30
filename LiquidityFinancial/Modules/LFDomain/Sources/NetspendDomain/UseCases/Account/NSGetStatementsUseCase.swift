import Foundation
  
public class NSGetStatementsUseCase: NSGetStatementsUseCaseProtocol {
  
  private let repository: NSAccountRepositoryProtocol
  
  public init(repository: NSAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionId: String, parameter: GetStatementParameterEntity) async throws -> [StatementModel] {
    try await repository.getStatements(sessionId: sessionId, parameter: parameter)
  }
}
