import Foundation

public protocol DeviceDeregisterUseCaseProtocol {
  func execute(deviceId: String, token: String) async throws -> NotificationTokenEntity
}
