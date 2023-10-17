import Foundation
import AccountDomain

// sourcery: AutoMockable
public protocol ZerohashRepositoryProtocol {
  func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity
  func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse
  func execute(accountId: String, quoteId: String) async throws -> TransactionEntity
  func getOnboardingStep() async throws -> ZHOnboardingStepEntity
}
