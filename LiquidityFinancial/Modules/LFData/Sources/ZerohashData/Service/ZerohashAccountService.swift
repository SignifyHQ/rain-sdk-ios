import Foundation
import AccountService
import Factory
import ZerohashDomain
import LFUtilities

public class ZerohashAccountService: AccountsServiceProtocol {
  
  @LazyInjected(\.zerohashAccountRepository) var zerohashAccountRepository
  
  lazy var getAccountUsecase: ZerohashGetAccountsUseCaseProtocol = {
    ZerohashGetAccountsUseCase(repository: zerohashAccountRepository)
  }()
  
  lazy var getAccountDetailUsecase: ZerohashGetAccountDetailUseCaseProtocol = {
    ZerohashGetAccountDetailUseCase(repository: zerohashAccountRepository)
  }()
  
  public init() {
    
  }
  
  public func getAccounts() async throws -> [AccountModel] {
    let entity = try await self.getAccountUsecase.execute()
    return entity.compactMap { account in
      AccountModel(
        id: account.id,
        externalAccountId: account.externalAccountId,
        currency: account.currency,
        availableBalance: account.availableBalance,
        availableUsdBalance: account.availableUsdBalance
      )
    }
  }
  
  public func getAccountDetail(id: String) async throws -> AccountModel {
    let entity = try await self.getAccountDetailUsecase.execute(id: id)
    guard let model = AccountModel(
      id: entity.id,
      externalAccountId: entity.externalAccountId,
      currency: entity.currency,
      availableBalance: entity.availableBalance,
      availableUsdBalance: entity.availableUsdBalance
    ) else {
      throw LiquidityError.invalidData
    }
    return model
  }
  
}
