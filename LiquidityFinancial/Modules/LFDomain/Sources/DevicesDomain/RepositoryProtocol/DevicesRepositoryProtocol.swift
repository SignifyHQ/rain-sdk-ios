import Foundation

// sourcery: AutoMockable
public protocol DevicesRepositoryProtocol {
  func register(deviceId: String, token: String) async throws -> NotificationTokenEntity
  func deregister(deviceId: String, token: String) async throws -> NotificationTokenEntity
}
