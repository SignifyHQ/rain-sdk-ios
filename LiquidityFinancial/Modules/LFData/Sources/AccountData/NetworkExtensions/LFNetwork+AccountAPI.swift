import Foundation
import DataUtilities
import LFNetwork
import LFUtilities

extension LFNetwork: AccountAPIProtocol where R == AccountRoute {
  public func getAccount(currencyType: String) async throws -> [APIAccount] {
    return try await request(AccountRoute.getAccount(currencyType: currencyType), target: [APIAccount].self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getUser(deviceId: String) async throws -> APIUser {
    return try await request(AccountRoute.getUser(deviceId: deviceId), target: APIUser.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func createZeroHashAccount() async throws -> APIZeroHashAccount {
    return try await request(AccountRoute.createZeroHashAccount, target: APIZeroHashAccount.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getTransactions(accountId: String, currencyType: String, limit: Int, offset: Int) async throws -> APITransactionList {
    let listModel = try await request(AccountRoute.getTransactions(accountId: accountId, currencyType: currencyType, limit: limit, offset: offset), target: APIListObject<APITransaction>.self, failure: LFErrorObject.self, decoder: .apiDecoder)
    return APITransactionList(total: listModel.total, data: listModel.data)
  }
  
  public func getTransactionDetail(accountId: String, transactionId: String) async throws -> APITransaction {
    try await request(
      AccountRoute.getTransactionDetail(accountId: accountId, transactionId: transactionId),
      target: APITransaction.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
