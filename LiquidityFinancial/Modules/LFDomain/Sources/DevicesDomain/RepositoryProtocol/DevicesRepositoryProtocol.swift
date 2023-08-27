import Foundation

public protocol DevicesRepositoryProtocol {
  func register(deviceId: String, token: String) async throws -> NotificationTokenResponse
  func deregister(deviceId: String, token: String) async throws -> NotificationTokenResponse
}
