import SolidDomain

public class SolidAccountRepository: SolidAccountRepositoryProtocol {
  private let accountAPI: SolidAccountAPIProtocol
  
  public init(accountAPI: SolidAccountAPIProtocol) {
    self.accountAPI = accountAPI
  }
  
  public func getAccounts() async throws -> [SolidAccountEntity] {
    return try await accountAPI.getAccounts()
  }
}
