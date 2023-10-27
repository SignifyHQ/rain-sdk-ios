import Foundation
  
public protocol NSGetCardRemainingAmountUseCaseProtocol {
  func execute(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity]
}
