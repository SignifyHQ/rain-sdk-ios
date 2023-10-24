import Foundation
import AuthorizationManager
import DevicesDomain
import LFUtilities

public class DevicesRepository: DevicesRepositoryProtocol {
  
  private let devicesAPI: DevicesAPIProtocol
  
  public init(devicesAPI: DevicesAPIProtocol) {
    self.devicesAPI = devicesAPI
  }
  
  public func register(deviceId: String, token: String) async throws -> NotificationTokenEntity {
    try await devicesAPI.register(deviceId: deviceId, token: token)
  }
  
  public func deregister(deviceId: String, token: String) async throws -> NotificationTokenEntity {
    try await devicesAPI.deregister(deviceId: deviceId, token: token)
  }
}

extension APINotificationTokenResponse: NotificationTokenEntity {}
