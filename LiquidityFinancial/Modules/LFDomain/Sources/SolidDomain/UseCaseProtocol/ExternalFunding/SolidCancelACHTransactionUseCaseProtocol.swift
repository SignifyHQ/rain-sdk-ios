import Foundation

public protocol SolidCancelACHTransactionUseCaseProtocol {
  func execute(liquidityTransactionID: String) async throws -> SolidExternalTransactionResponseEntity
}
