import Foundation

public protocol AccountRepositoryProtocol {
  func createZeroHashAccount() async throws -> ZeroHashAccount
  func getUser(deviceId: String) async throws -> LFUser
  func getAccount(currencyType: String) async throws -> [LFAccount]
}
