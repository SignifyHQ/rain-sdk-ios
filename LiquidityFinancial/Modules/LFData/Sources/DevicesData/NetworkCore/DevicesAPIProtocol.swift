import Foundation

// sourcery: AutoMockable
public protocol DevicesAPIProtocol {
  func register(deviceId: String, token: String) async throws -> APINotificationTokenResponse
  func deregister(deviceId: String, token: String) async throws -> APINotificationTokenResponse
}
