import Foundation

public final class RewardUseCase: RewardUseCaseProtocol {
  
  private let repository: RewardRepositoryProtocol
  
  public init(repository: RewardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func selectReward(body: [String: Any]) async throws -> SelectRewardEntity {
    return try await self.repository.selectRewardType(body: body)
  }
  
  public func getDonationCategories(limit: Int, offset: Int) async throws -> RewardCategoriesListEntity {
    return try await self.repository.getDonationCategories(limit: limit, offset: offset)
  }
  
  public func getCategoriesFundraisers(categoryID: String, limit: Int, offset: Int) async throws -> CategoriesFundraisersListEntity {
    return try await self.repository.getCategoriesFundraisers(categoryID: categoryID, limit: limit, offset: offset)
  }
  
  public func getFundraisersDetail(fundraiserID: String) async throws -> any FundraisersDetailEntity {
    return try await self.repository.getFundraisersDetail(fundraiserID: fundraiserID)
  }
  
  public func selectFundraiser(body: [String: Any]) async throws -> SelectFundraiserEntity {
    return try await self.repository.selectFundraiser(body: body)
  }
  
  public func setRoundUpDonation(body: [String: Any]) async throws -> RoundUpDonationEntity {
    return try await self.repository.setRoundUpDonation(body: body)
  }
}
