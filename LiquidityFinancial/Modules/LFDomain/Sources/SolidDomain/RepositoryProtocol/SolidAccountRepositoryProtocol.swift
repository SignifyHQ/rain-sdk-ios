import Foundation

// sourcery: AutoMockable
public protocol SolidAccountRepositoryProtocol {
  func getAccounts() async throws -> [SolidAccountEntity]
}
