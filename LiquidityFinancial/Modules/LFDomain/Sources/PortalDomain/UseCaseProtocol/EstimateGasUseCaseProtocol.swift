import Foundation
import Services

public protocol EstimateGasUseCaseProtocol {
  func estimateTransferFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double
  func estimateWithdrawalFee(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> Double
}
