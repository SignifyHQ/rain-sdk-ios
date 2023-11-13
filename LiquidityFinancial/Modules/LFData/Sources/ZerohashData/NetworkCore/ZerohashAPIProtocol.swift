import Foundation
import AccountData
import ZerohashDomain

// sourcery: AutoMockable
public protocol ZerohashAPIProtocol {
  func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> APITransaction
  func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse
  func execute(accountId: String, quoteId: String) async throws -> APITransaction
  func getOnboardingStep() async throws -> APIZHOnboardingStep
  func getTaxFile(accountId: String) async throws -> [APITaxFile]
  func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL
}
