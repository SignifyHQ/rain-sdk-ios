import Foundation

// sourcery: AutoMockable
public protocol ZerohashAccountRepositoryProtocol {
  func getAccounts() async throws -> [ZerohashAccountEntity]
  func getAccountDetail(id: String) async throws -> ZerohashAccountEntity
}
