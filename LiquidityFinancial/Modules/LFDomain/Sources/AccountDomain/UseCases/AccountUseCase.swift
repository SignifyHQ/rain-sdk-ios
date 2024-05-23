import Foundation

public final class AccountUseCase: AccountUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func logout() async throws -> Bool {
    return try await repository.logout()
  }
  
  public func getReferralCampaign() async throws -> ReferralCampaignEntity {
    return try await repository.getReferralCampaign()
  }
  
  public func addToWaitList(waitList: String) async throws -> Bool {
    return try await repository.addToWaitList(waitList: waitList)
  }
  
  public func getUserRewards() async throws -> [UserRewardsEntity] {
    return try await repository.getUserRewards()
  }
  
  public func getFeatureConfig() async throws -> AccountFeatureConfigEntity {
    return try await repository.getFeatureConfig()
  }
}
