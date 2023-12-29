import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities
import AccountData
import ZerohashDomain

extension LFCoreNetwork: ZerohashAPIProtocol where R == ZerohashRoute {
  public func buyCrypto(accountId: String, quoteId: String) async throws -> APIBuyCrypto {
    return try await request(ZerohashRoute.buyCrypto(accountId: accountId, quoteId: quoteId),
                             target: APIBuyCrypto.self,
                             failure: LFErrorObject.self,
                             decoder: .apiDecoder)
  }
  
  public func getBuyQuote(accountId: String, amount: String?, quantity: String?) async throws -> APIGetBuyQuote {
    return try await request(ZerohashRoute.getBuyQuote(accountId: accountId, amount: amount, quantity: quantity),
                             target: APIGetBuyQuote.self,
                             failure: LFErrorObject.self,
                             decoder: .apiDecoder)
  }
  
  public func sellCrypto(accountId: String, quoteId: String) async throws -> APISellCrypto {
    return try await request(ZerohashRoute.sellCrypto(accountId: accountId, quoteId: quoteId),
                             target: APISellCrypto.self,
                             failure: LFErrorObject.self,
                             decoder: .apiDecoder)
  }
  
  public func getSellQuote(accountId: String, amount: String?, quantity: String?) async throws -> APIGetSellQuote {
    return try await request(ZerohashRoute.getSellQuote(accountId: accountId, amount: amount, quantity: quantity),
                             target: APIGetSellQuote.self,
                             failure: LFErrorObject.self,
                             decoder: .apiDecoder)
  }
  
  
  public func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> APITransaction {
    return try await request(
      ZerohashRoute.sendCrypto(accountId: accountId, destinationAddress: destinationAddress, amount: amount),
      target: APITransaction.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse {
    return try await request(
      ZerohashRoute.lockedNetworkFee(
        accountId: accountId,
        destinationAddress: destinationAddress,
        amount: amount,
        maxAmount: maxAmount
      ),
      target: APILockedNetworkFeeResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func execute(accountId: String, quoteId: String) async throws -> APITransaction {
    return try await request(
      ZerohashRoute.executeQuote(accountId: accountId, quoteId: quoteId),
      target: APITransaction.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getOnboardingStep() async throws -> APIZHOnboardingStep {
    let result = try await request(ZerohashRoute.getOnboardingStep, target: [String].self, decoder: .apiDecoder)
    return APIZHOnboardingStep(missingSteps: result)
  }
  
  public func getTaxFile(accountId: String) async throws -> [APITaxFile] {
    return try await request(
      ZerohashRoute.getTaxFile(accountId: accountId),
      target: [APITaxFile].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL {
    return try await download(ZerohashRoute.getTaxFileYear(accountId: accountId, year: year), fileName: fileName)
  }
}
