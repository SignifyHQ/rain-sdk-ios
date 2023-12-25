import Foundation
import AccountDomain

// sourcery: AutoMockable
public protocol ZerohashRepositoryProtocol {
  func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity
  func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse
  func execute(accountId: String, quoteId: String) async throws -> TransactionEntity
  func getOnboardingStep() async throws -> ZHOnboardingStepEntity
  func getTaxFile(accountId: String) async throws -> [any TaxFileEntity]
  func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL
  func sellCrypto(accountId: String, quoteId: String) async throws -> SellCryptoEntity
  func getSellQuote(accountId: String, amount: String?, quantity: String?) async throws -> GetSellQuoteEntity
}
