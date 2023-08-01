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
}
