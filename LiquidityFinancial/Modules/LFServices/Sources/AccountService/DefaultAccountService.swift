import Foundation

public struct DefaultAccountService: AccountsServiceProtocol {
  
  public init() {
  }
  
  public func getAccounts() -> [AccountModel] {
    []
  }
  
  public func getAccountDetail(id: String) async throws -> AccountModel {
    AccountModel(
      id: "",
      externalAccountId: nil,
      currency: CurrencyType.USD.rawValue,
      availableBalance: 0,
      availableUsdBalance: 0
    )!
  }
  
}
