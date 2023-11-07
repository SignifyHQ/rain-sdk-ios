import Foundation

// sourcery: AutoMockable
public protocol ZerohashAccountAPIProtocol {
  func getAccounts() async throws -> [APIZerohashAccount]
  func getAccountDetail(id: String) async throws -> APIZerohashAccount
}
