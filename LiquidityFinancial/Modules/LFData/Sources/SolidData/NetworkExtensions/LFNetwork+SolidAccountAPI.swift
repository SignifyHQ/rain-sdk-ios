import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidAccountAPIProtocol where R == SolidAccountRoute {
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
