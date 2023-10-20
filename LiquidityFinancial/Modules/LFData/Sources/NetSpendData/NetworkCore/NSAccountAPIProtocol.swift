import Foundation
import NetspendDomain

// sourcery: AutoMockable
public protocol NSAccountAPIProtocol {
  func getStatements(sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String) async throws -> [StatementModel]
}
