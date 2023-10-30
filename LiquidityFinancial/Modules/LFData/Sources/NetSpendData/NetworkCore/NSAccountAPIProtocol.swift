import Foundation
import NetspendDomain

// sourcery: AutoMockable
public protocol NSAccountAPIProtocol {
  func getStatements(sessionId: String, parameters: GetStatementParameters) async throws -> [StatementModel]
}
