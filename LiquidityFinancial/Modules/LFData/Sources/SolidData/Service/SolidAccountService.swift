import AccountService
import SolidData
import Factory
import SolidDomain

public class SolidAccountService: AccountsServiceProtocol {
  
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  
  lazy var getAccountUsecase: SolidGetAccountsUseCaseProtocol = {
    SolidGetAccountsUseCase(repository: solidAccountRepository)
  }()
  
  public init() {
    
  }
  
  public func getFiatAccounts() async throws -> [AccountModel] {
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
  
}
