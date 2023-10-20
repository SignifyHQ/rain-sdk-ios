import SolidDomain

public class SolidLinkSourceRepository: LinkSourceRepositoryProtocol {
  
  private let solidAPI: SolidAPIProtocol
  
  public init(solidAPI: SolidAPIProtocol) {
    self.solidAPI = solidAPI
  }
  
  public func createPlaidToken(accountID: String) async throws -> CreatePlaidTokenResponseEntity {
    try await solidAPI.createPlaidToken(accountId: accountID)
  }
  
  public func linkPlaid(accountId: String, token: String, plaidAccountId: String) async throws -> SolidContactEntity {
    let data = try await solidAPI.plaidLink(accountId: accountId, token: token, plaidAccountId: plaidAccountId)
    return data
  }
  
}
