import Foundation

public protocol AccountsServiceProtocol {
  
  func getFiatAccounts() async throws -> [AccountModel]
  
}
