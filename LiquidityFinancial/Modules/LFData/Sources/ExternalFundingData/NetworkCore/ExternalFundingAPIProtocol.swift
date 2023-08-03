import Foundation

public protocol ExternalFundingAPIProtocol {
  func set(request: ExternalCardParameters, sessionID: String) async throws -> APIExternalCard
  func getPinWheelToken(sessionID: String) async throws -> APIPinWheelToken
  func getACHInfo(sessionID: String) async throws -> APIACHInfo
}
