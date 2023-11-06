import Foundation

public protocol AccountsServiceProtocol {
  
  func getAccounts() async throws -> [AccountModel]
  func getAccountDetail(id: String) async throws -> AccountModel
  
}
