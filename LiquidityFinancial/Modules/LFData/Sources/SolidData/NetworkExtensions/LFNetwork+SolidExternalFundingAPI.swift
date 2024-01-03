import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities
import SolidDomain

extension LFCoreNetwork: SolidExternalFundingAPIProtocol where R == SolidExternalFundingRoute {
  
  public func getLinkedSources(accountId: String) async throws -> [APISolidContact] {
    try await request(
      SolidExternalFundingRoute.getLinkedSources(accountId: accountId),
      target: [APISolidContact].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createDebitCardToken(accountID: String) async throws -> APISolidDebitCardToken {
    try await request(
      SolidExternalFundingRoute.createDebitCardToken(accountID: accountID),
      target: APISolidDebitCardToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createPlaidToken(accountId: String) async throws -> APICreatePlaidTokenResponse {
    return try await request(
      SolidExternalFundingRoute.createPlaidToken(accountId: accountId),
      target: APICreatePlaidTokenResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> APISolidContact {
    return try await request(
      SolidExternalFundingRoute.plaidLink(accountId: accountId, token: token, plaidAccountId: plaidAccountId),
      target: APISolidContact.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func unlinkContact(id: String) async throws -> APISolidUnlinkContactResponse {
    let response = try await request(SolidExternalFundingRoute.unlinkContact(id: id))
    
    let statusCode = (response.httpResponse?.statusCode ?? 500).isSuccess
    if !statusCode, let data = response.data {
      try LFCoreNetwork.processingStringError(data)
    }
    
    return APISolidUnlinkContactResponse(success: statusCode)
  }
  
  public func getWireTransfer(accountId: String) async throws -> APISolidWireTransferResponse {
    return try await request(
      SolidExternalFundingRoute.getWireTransfer(accountId: accountId),
      target: APISolidWireTransferResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func newTransaction(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double) async throws -> APISolidExternalTransactionResponse {
    return try await request(
      SolidExternalFundingRoute.newTransaction(type: type, accountId: accountId, contactId: contactId, amount: amount),
      target: APISolidExternalTransactionResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func estimateDebitCardFee(accountId: String, contactId: String, amount: Double) async throws -> APISolidDebitCardTransferFeeResponse {
    return try await request(
      SolidExternalFundingRoute.estimateDebitCardFee(accountId: accountId, contactId: contactId, amount: amount),
      target: APISolidDebitCardTransferFeeResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createPinwheelToken(accountId: String) async throws -> APISolidExternalPinwheelTokenResponse {
    return try await request(
      SolidExternalFundingRoute.createPinwheelToken(accountId: accountId),
      target: APISolidExternalPinwheelTokenResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func cancelACHTransaction(liquidityTransactionID: String) async throws -> APISolidExternalTransactionResponse {
    try await request(
      SolidExternalFundingRoute.cancelACHTransaction(liquidityTransactionID: liquidityTransactionID),
      target: APISolidExternalTransactionResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
