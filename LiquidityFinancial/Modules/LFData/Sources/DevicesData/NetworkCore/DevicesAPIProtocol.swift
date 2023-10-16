import Foundation
import DevicesDomain

// sourcery: AutoMockable
public protocol DevicesAPIProtocol {
  func register(deviceId: String, token: String) async throws -> NotificationTokenResponse
  func deregister(deviceId: String, token: String) async throws -> NotificationTokenResponse
}
