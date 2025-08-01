import Foundation
import LinkSDK

public protocol MeshServiceProtocol {
  func showMeshFlow(
    with linkToken: String,
    accountId: String?,
    accountName: String?,
    accessToken: String?,
    brokerType: String?,
    brokerName: String?
  ) async throws -> AccessTokenPayload?
}
