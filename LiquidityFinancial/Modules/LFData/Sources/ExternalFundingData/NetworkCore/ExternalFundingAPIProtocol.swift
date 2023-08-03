import Foundation

public protocol ExternalFundingAPIProtocol {
  func set(request: ExternalCardParameters, sessionID: String) async throws -> APIExternalCard
}
