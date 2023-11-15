import Foundation

// sourcery: AutoMockable
public protocol SolidAccountRepositoryProtocol {
  func getAccounts() async throws -> [SolidAccountEntity]
  func getAccountDetail(id: String) async throws -> SolidAccountEntity
  func getAccountLimits() async throws -> [SolidAccountLimitsEntity]
  func getStatement(liquidityAccountId: String, fileName: String, year: String, month: String) async throws -> SolidAccountStatementItemEntity
  func getAllStatement(liquidityAccountId: String) async throws -> [SolidAccountStatementListEntity]
}
