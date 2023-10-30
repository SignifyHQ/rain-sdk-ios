import Foundation

public protocol NSAccountRepositoryProtocol {
  func getStatements(sessionId: String, parameter: GetStatementParameterEntity) async throws -> [StatementModel]
}
