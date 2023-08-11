import Foundation
import NetSpendDomain
import DataUtilities
import LFNetwork
import LFUtilities

extension LFNetwork: NSAccountAPIProtocol where R == NSAccountRoute {
  
  public func getStatements(sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String) async throws -> [StatementModel] {
    let response = try await request(
      NSAccountRoute.getStatements(
        sessionId: sessionId,
        fromMonth: fromMonth,
        fromYear: fromYear,
        toMonth: toMonth,
        toYear: toYear
      ),
      target: StatementListReponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return response.statements
  }
}
