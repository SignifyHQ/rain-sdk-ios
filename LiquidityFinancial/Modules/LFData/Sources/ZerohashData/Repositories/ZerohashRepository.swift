import Foundation
import ZerohashDomain
import AccountDomain
import LFUtilities

public class ZerohashRepository: ZerohashRepositoryProtocol {
  private let zerohashAPI: ZerohashAPIProtocol
  
  public init(zerohashAPI: ZerohashAPIProtocol) {
    self.zerohashAPI = zerohashAPI
  }
  
  public func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity {
    return try await self.zerohashAPI.sendCrypto(accountId: accountId, destinationAddress: destinationAddress, amount: amount)
  }
  
  public func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse {
    return try await self.zerohashAPI.lockedNetworkFee(
      accountId: accountId,
      destinationAddress: destinationAddress,
      amount: amount,
      maxAmount: maxAmount
    )
  }
  
  public func execute(accountId: String, quoteId: String) async throws -> TransactionEntity {
    return try await self.zerohashAPI.execute(
      accountId: accountId, quoteId: quoteId
    )
  }
  
  public func getOnboardingStep() async throws -> ZHOnboardingStepEntity {
    return try await self.zerohashAPI.getOnboardingStep()
  }
  
  public func getTaxFile(accountId: String) async throws -> [any TaxFileEntity] {
    try await self.zerohashAPI.getTaxFile(accountId: accountId)
  }
  
  public func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL {
    try await self.zerohashAPI.getTaxFileYear(accountId: accountId, year: year, fileName: fileName)
  }
  
  public func getSellQuote(accountId: String, amount: String?, quantity: String?) async throws -> GetSellQuoteEntity {
    try await self.zerohashAPI.getSellQuote(accountId: accountId, amount: amount, quantity: quantity)
  }
  
  public func sellCrypto(accountId: String, quoteId: String) async throws -> SellCryptoEntity {
    try await self.zerohashAPI.sellCrypto(accountId: accountId, quoteId: quoteId)
  }
}

extension APIZHOnboardingStep: ZHOnboardingStepEntity {}
