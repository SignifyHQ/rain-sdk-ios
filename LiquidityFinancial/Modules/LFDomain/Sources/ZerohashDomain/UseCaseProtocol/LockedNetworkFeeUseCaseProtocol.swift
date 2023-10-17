import Foundation

public protocol LockedNetworkFeeUseCaseProtocol {
  func execute(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse
}
