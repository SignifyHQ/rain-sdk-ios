import Foundation
import NetspendDomain

public class NSAccountRepository: NSAccountRepositoryProtocol {
  private let accountAPI: NSAccountAPIProtocol
  
  public init(accountAPI: NSAccountAPIProtocol) {
    self.accountAPI = accountAPI
  }
  
  public func getStatements(sessionId: String, parameter: GetStatementParameterEntity) async throws -> [StatementModel] {
    let requestParam = GetStatementParameters(
      fromMonth: parameter.fromMonth,
      fromYear: parameter.fromYear,
      toMonth: parameter.toMonth,
      toYear: parameter.toYear
    )
    return try await accountAPI.getStatements(sessionId: sessionId, parameters: requestParam)
  }
  
  public func getAccounts() async throws -> [NSAccountEntity] {
    return try await accountAPI.getAccounts()
  }
  
  public func getAccountDetail(id: String) async throws -> NSAccountEntity {
    return try await accountAPI.getAccountDetail(id: id)
  }
}
