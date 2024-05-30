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
}
