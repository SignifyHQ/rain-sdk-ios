import SolidDomain

public class SolidExternalFundingRepository: SolidExternalFundingRepositoryProtocol {
  
  private let solidExternalFundingAPI: SolidExternalFundingAPIProtocol
  
  public init(solidExternalFundingAPI: SolidExternalFundingAPIProtocol) {
    self.solidExternalFundingAPI = solidExternalFundingAPI
  }
  
  public func getLinkedSources(accountID: String) async throws -> [SolidContactEntity] {
    try await solidExternalFundingAPI.getLinkedSources(accountId: accountID)
  }
  
  public func createDebitCardToken(accountID: String) async throws -> SolidDebitCardTokenEntity {
    try await solidExternalFundingAPI.createDebitCardToken(accountID: accountID)
  }
  
  public func createPlaidToken(accountID: String) async throws -> CreatePlaidTokenResponseEntity {
    try await solidExternalFundingAPI.createPlaidToken(accountId: accountID)
  }
  
  public func linkPlaid(accountId: String, token: String, plaidAccountId: String) async throws -> SolidContactEntity {
    let data = try await solidExternalFundingAPI.plaidLink(
      accountId: accountId,
      token: token,
      plaidAccountId: plaidAccountId
    )
    return data
  }
  
  public func unlinkContact(id: String) async throws -> SolidUnlinkContactResponseEntity {
    try await solidExternalFundingAPI.unlinkContact(id: id)
  }
  
  public func getWireTransfer(accountId: String) async throws -> SolidWireTransferResponseEntity {
    try await solidExternalFundingAPI.getWireTransfer(accountId: accountId)
  }
  
  public func newTransaction(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double) async throws -> SolidExternalTransactionResponseEntity {
    try await solidExternalFundingAPI.newTransaction(type: type, accountId: accountId, contactId: contactId, amount: amount)
  }
  
}
