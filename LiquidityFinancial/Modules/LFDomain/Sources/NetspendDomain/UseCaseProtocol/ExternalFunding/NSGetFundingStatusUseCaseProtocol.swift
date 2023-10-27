import Foundation
  
public protocol NSGetFundingStatusUseCaseProtocol {
  func execute(sessionID: String) async throws -> any ExternalFundingsatusEntity
}
