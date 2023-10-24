import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: DevicesAPIProtocol where R == DeviceRoute {
  
  public func register(deviceId: String, token: String) async throws -> APINotificationTokenResponse {
    let result = try await request(
      DeviceRoute.register(deviceId: deviceId, token: token)
    )
    let statusCode = result.httpResponse?.statusCode ?? 500
    return APINotificationTokenResponse(success: statusCode.isSuccess)
  }
  
  public func deregister(deviceId: String, token: String) async throws -> APINotificationTokenResponse {
    let result = try await request(
      DeviceRoute.deregister(deviceId: deviceId, token: token)
    )
    let statusCode = result.httpResponse?.statusCode ?? 500
    return APINotificationTokenResponse(success: statusCode.isSuccess)
  }
}
