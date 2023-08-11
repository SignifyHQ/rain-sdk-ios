import Foundation
import NetSpendDomain

public class NSAccountRepository: NSAccountRepositoryProtocol {
  private let accountAPI: NSAccountAPIProtocol
  
  public init(accountAPI: NSAccountAPIProtocol) {
    self.accountAPI = accountAPI
  }
  
  public func getStatements(sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String) async throws -> [StatementModel] {
    try await accountAPI.getStatements(
      sessionId: sessionId,
      fromMonth: fromMonth,
      fromYear: fromYear,
      toMonth: toMonth,
      toYear: toYear
    )
  }
}
