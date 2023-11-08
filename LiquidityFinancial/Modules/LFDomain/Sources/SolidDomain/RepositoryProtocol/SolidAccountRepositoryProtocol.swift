import Foundation

// sourcery: AutoMockable
public protocol SolidAccountRepositoryProtocol {
  func getAccounts() async throws -> [SolidAccountEntity]
  func getAccountDetail(id: String) async throws -> SolidAccountEntity
  func getAccountLimits() async throws -> [SolidAccountLimitsEntity]
}
