import AccountService
import Factory
import NetspendDomain
import NetSpendData

public class NetspendAccountService: AccountsServiceProtocol {
  
  @LazyInjected(\.nsAccountRepository) var nsAccountRepository
  
  lazy var getAccountUsecase: NSGetAccountsUseCaseProtocol = {
    NSGetAccountsUseCase(repository: nsAccountRepository)
  }()
  
  public init() {
  }
  
  public func getFiatAccounts() async throws  -> [AccountModel] {
    let entity = try await self.getAccountUsecase.execute()
    return entity.compactMap { nsAccount in
      AccountModel(
        id: nsAccount.id,
        externalAccountId: nsAccount.externalAccountId,
        currency: nsAccount.currency,
        availableBalance: nsAccount.availableBalance,
        availableUsdBalance: nsAccount.availableUsdBalance
      )
    }
  }
  
}
