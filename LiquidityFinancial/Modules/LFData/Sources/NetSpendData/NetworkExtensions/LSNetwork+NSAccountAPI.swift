import Foundation
import NetspendDomain
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: NSAccountAPIProtocol where R == NSAccountRoute {
  
  public func getStatements(sessionId: String, parameters: GetStatementParameters) async throws -> [StatementModel] {
    let response = try await request(
      NSAccountRoute.getStatements( sessionId: sessionId, parameters: parameters),
      target: StatementListReponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return response.statements
  }
  
  public func getAccounts() async throws -> [APINetspendAccount] {
    return try await request(
      NSAccountRoute.getAccounts,
      target: [APINetspendAccount].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
