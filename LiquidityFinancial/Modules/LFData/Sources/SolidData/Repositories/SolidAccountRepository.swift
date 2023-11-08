import SolidDomain

public class SolidAccountRepository: SolidAccountRepositoryProtocol {
  private let accountAPI: SolidAccountAPIProtocol
  
  public init(accountAPI: SolidAccountAPIProtocol) {
    self.accountAPI = accountAPI
  }
  
  public func getAccounts() async throws -> [SolidAccountEntity] {
    return try await accountAPI.getAccounts()
  }
  
  public func getAccountDetail(id: String) async throws -> SolidAccountEntity {
    return try await accountAPI.getAccountDetail(id: id)
  }
  
  public func getAccountLimits() async throws -> [SolidDomain.SolidAccountLimitsEntity] {
    return try await accountAPI.getAccountLimits()
  }
}
