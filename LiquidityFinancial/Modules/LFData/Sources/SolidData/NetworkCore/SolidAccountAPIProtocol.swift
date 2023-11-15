import Foundation

// sourcery: AutoMockable
public protocol SolidAccountAPIProtocol {
  func getAccounts() async throws -> [APISolidAccount]
  func getAccountDetail(id: String) async throws -> APISolidAccount
  func getAccountLimits() async throws -> [APISolidAccountLimits]
  func getAllStatement(liquidityAccountId: String) async throws -> [APISolidAccountStatementList]
  func getStatement(liquidityAccountId: String, fileName: String, year: String, month: String) async throws -> APISolidAccountStatementItem
}
