import Foundation

// sourcery: AutoMockable
public protocol NSAccountRepositoryProtocol {
  func getStatements(sessionId: String, parameter: GetStatementParameterEntity) async throws -> [StatementModel]
  func getAccounts() async throws -> [NSAccountEntity]
  func getAccountDetail(id: String) async throws -> NSAccountEntity
  func getAccountLimits() async throws -> any NSAccountLimitsEntity
}
