import Foundation
import Services

public final class WithdrawAssetUseCase: WithdrawAssetUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> String {
    try await repository.withdrawAsset(addresses: addresses, amount: amount, signature: signature)
  }
}
