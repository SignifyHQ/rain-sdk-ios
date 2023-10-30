import Foundation

public protocol NSGetStatementsUseCaseProtocol {
  func execute(sessionId: String, parameter: GetStatementParameterEntity) async throws -> [StatementModel]
}
