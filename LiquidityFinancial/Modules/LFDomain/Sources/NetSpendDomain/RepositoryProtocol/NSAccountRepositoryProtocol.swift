import Foundation

public protocol NSAccountRepositoryProtocol {
  mutating func getStatements(sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String) async throws -> [StatementModel]
}
