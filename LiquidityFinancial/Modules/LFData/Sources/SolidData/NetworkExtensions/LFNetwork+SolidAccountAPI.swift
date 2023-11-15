import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidAccountAPIProtocol where R == SolidAccountRoute {
  public func getAllStatement(liquidityAccountId: String) async throws -> [APISolidAccountStatementList] {
    return try await request(
      SolidAccountRoute.getAllStatement(liquidityAccountId: liquidityAccountId),
      target: [APISolidAccountStatementList].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getStatement(liquidityAccountId: String, fileName: String, year: String, month: String) async throws -> APISolidAccountStatementItem {
    let result = try await download(
      SolidAccountRoute.getStatementItem(
        liquidityAccountId: liquidityAccountId,
        year: year,
        month: month
      ),
      fileName: fileName,
      type: .pdf
    )
    return APISolidAccountStatementItem(url: result)
  }
  
  public func getAccountLimits() async throws -> [APISolidAccountLimits] {
    return try await request(
      SolidAccountRoute.getAccountLimits,
      target: [APISolidAccountLimits].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getAccounts() async throws -> [APISolidAccount] {
    return try await request(
      SolidAccountRoute.getAccounts,
      target: [APISolidAccount].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getAccountDetail(id: String) async throws -> APISolidAccount {
    return try await request(
      .getAccountDetail(id: id),
      target: APISolidAccount.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
}
