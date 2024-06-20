import Foundation
import Services

public final class EstimateGasUseCase: EstimateGasUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func estimateTransferFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double {
    try await repository.estimateTransferFee(to: address, contractAddress: contractAddress, amount: amount)
  }
  
  public func estimateWithdrawalFee(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> Double {
    try await repository.estimateWithdrawalFee(addresses: addresses, amount: amount, signature: signature)
  }
}
