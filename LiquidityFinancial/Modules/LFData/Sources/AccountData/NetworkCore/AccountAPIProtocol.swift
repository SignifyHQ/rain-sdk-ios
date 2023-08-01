import Foundation
import DataUtilities

public protocol AccountAPIProtocol {
  func createZeroHashAccount() async throws -> APIZeroHashAccount
  func getUser(deviceId: String) async throws -> APIUser
  func getAccount(currencyType: String) async throws -> [APIAccount]
}
