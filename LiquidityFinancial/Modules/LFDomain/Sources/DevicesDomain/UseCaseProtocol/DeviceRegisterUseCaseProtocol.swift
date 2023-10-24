import Foundation

public protocol DeviceRegisterUseCaseProtocol {
  func execute(deviceId: String, token: String) async throws -> NotificationTokenEntity
}
