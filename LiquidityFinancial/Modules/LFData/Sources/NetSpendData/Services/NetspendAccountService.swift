import AccountService
import Factory
import NetspendDomain
import LFUtilities

public class NetspendAccountService: AccountsServiceProtocol {
  
  @LazyInjected(\.nsAccountRepository) var nsAccountRepository
  
  lazy var getAccountUsecase: NSGetAccountsUseCaseProtocol = {
    NSGetAccountsUseCase(repository: nsAccountRepository)
  }()
  
  lazy var getAccountDetailUsecase: NSGetAccountDetailUseCaseProtocol = {
    NSGetAccountDetailUseCase(repository: nsAccountRepository)
  }()
  
  public init() {
  }
  
  public func getAccounts() async throws -> [AccountModel] {
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
  
  public func getAccountDetail(id: String) async throws -> AccountModel {
    let entity = try await getAccountDetailUsecase.execute(id: id)
    guard let accountModel = AccountModel(
      id: entity.id,
      externalAccountId: entity.externalAccountId,
      currency: entity.currency,
      availableBalance: entity.availableBalance,
      availableUsdBalance: entity.availableUsdBalance
    ) else {
      throw LiquidityError.invalidData
    }
    return accountModel
  }
  
}
