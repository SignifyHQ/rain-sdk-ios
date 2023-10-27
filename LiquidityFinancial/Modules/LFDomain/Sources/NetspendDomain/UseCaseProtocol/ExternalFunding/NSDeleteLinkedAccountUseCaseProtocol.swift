import Foundation
  
public protocol NSDeleteLinkedAccountUseCaseProtocol {
  func execute(
    sessionId: String,
    sourceId: String,
    sourceType: String
  ) async throws -> UnlinkBankEntity
}
