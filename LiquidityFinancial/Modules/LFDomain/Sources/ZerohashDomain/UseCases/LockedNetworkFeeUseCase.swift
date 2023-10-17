import Foundation

public class LockedNetworkFeeUseCase: LockedNetworkFeeUseCaseProtocol {
  
  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse {
    return try await repository
      .lockedNetworkFee(
        accountId: accountId,
        destinationAddress: destinationAddress,
        amount: amount,
        maxAmount: maxAmount
      )
  }
  
}
