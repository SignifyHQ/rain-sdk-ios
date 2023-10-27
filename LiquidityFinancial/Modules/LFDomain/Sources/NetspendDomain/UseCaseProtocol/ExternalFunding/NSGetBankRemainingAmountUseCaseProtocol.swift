import Foundation
  
public protocol NSGetBankRemainingAmountUseCaseProtocol {
  func execute(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity]
}
