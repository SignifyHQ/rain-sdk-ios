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
  
  public func getStatement(liquidityAccountId: String, fileName: String, year: String, month: String) async throws -> SolidAccountStatementItemEntity {
    return try await accountAPI.getStatement(liquidityAccountId: liquidityAccountId, fileName: fileName, year: year, month: month)
  }
  
  public func getAllStatement(liquidityAccountId: String) async throws -> [SolidAccountStatementListEntity] {
    return try await accountAPI.getAllStatement(liquidityAccountId: liquidityAccountId)
  }
}
