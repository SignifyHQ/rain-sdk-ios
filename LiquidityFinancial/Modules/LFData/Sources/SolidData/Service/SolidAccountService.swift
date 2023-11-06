import AccountService
import SolidData
import Factory
import SolidDomain
import LFUtilities

public class SolidAccountService: AccountsServiceProtocol {
  
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  
  lazy var getAccountUsecase: SolidGetAccountsUseCaseProtocol = {
    SolidGetAccountsUseCase(repository: solidAccountRepository)
  }()
  
  lazy var getAccountDetailUsecase: SolidGetAccountDetailUseCaseProtocol = {
    SolidGetAccountDetailUseCase(repository: solidAccountRepository)
  }()
  
  public init() {
    
  }
  
  public func getAccounts() async throws -> [AccountModel] {
    let entity = try await self.getAccountUsecase.execute()
    return entity.compactMap { solidAccount in
      AccountModel(
        id: solidAccount.id,
        externalAccountId: solidAccount.externalAccountId,
        currency: solidAccount.currency,
        availableBalance: solidAccount.availableBalance,
        availableUsdBalance: solidAccount.availableUsdBalance
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
