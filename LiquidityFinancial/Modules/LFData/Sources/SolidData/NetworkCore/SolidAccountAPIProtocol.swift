import Foundation

// sourcery: AutoMockable
public protocol SolidAccountAPIProtocol {
  func getAccounts() async throws -> [APISolidAccount]
  func getAccountDetail(id: String) async throws -> APISolidAccount
  func getAccountLimits() async throws -> [APISolidAccountLimits]
}
