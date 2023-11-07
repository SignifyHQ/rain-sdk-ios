import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: ZerohashAccountAPIProtocol where R == ZerohashAccountRoute {
  
  public func getAccounts() async throws -> [APIZerohashAccount] {
    return try await request(
      .getAccounts,
      target: [APIZerohashAccount].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getAccountDetail(id: String) async throws -> APIZerohashAccount {
    return try await request(
      .getAccountDetail(id: id),
      target: APIZerohashAccount.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
}
