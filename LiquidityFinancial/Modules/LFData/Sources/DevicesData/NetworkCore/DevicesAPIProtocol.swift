import Foundation
import NetworkUtilities
import LFUtilities
import DevicesDomain

public protocol DevicesAPIProtocol {
  func register(deviceId: String, token: String) async throws -> NotificationTokenResponse
  func deregister(deviceId: String, token: String) async throws -> NotificationTokenResponse
}
