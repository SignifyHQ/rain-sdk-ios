import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: RainRewardAPIProtocol where R == RainRewardRoute {
  public func getRewardBalance() async throws -> APIRainRewardBalances {
    let listModel = try await request(
      RainRewardRoute.getRewardBalance,
      target: APIListObject<APIRainRewardBalance>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    
    return APIRainRewardBalances(data: listModel.data)
  }
  
  public func requestRewardWithdrawal(parameters: APIRainRewardWithdrawalParameters) async throws {
    try await requestNoResponse(
      RainRewardRoute.requestRewardWithdrawal(parameters: parameters),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
