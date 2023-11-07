import ZerohashDomain

public class ZerohashAccountRepository: ZerohashAccountRepositoryProtocol {
  private let accountAPI: ZerohashAccountAPIProtocol
  
  public init(accountAPI: ZerohashAccountAPIProtocol) {
    self.accountAPI = accountAPI
  }
  
  public func getAccounts() async throws -> [ZerohashAccountEntity] {
    return try await accountAPI.getAccounts()
  }
  
  public func getAccountDetail(id: String) async throws -> ZerohashAccountEntity {
    return try  await accountAPI.getAccountDetail(id: id)
  }
}
