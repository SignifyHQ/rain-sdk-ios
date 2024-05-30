import Foundation
import RainDomain

public class RainRewardRepository: RainRewardRepositoryProtocol {
  private let rainRewardAPI: RainRewardAPIProtocol
  
  public init(rainRewardAPI: RainRewardAPIProtocol) {
    self.rainRewardAPI = rainRewardAPI
  }
  
  public func getRewardBalance() async throws -> RainRewardBalanceEntity {
    try await rainRewardAPI.getRewardBalance()
  }
  
  public func requestRewardWithdrawal(parameters: RainRewardWithdrawalParametersEntity) async throws {
    guard let parameters = parameters as? APIRainRewardWithdrawalParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    
    return try await rainRewardAPI.requestRewardWithdrawal(parameters: parameters)
  }
}
