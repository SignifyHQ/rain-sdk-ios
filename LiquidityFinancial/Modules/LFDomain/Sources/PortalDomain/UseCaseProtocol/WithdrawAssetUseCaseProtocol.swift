import Foundation
import Services

public protocol WithdrawAssetUseCaseProtocol {
  func execute(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> String
}
