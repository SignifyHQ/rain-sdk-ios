import Foundation
import NetSpendDomain

public protocol NSAccountAPIProtocol {
  func getStatements(sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String) async throws -> [StatementModel]
}
