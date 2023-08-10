import Foundation
import AccountDomain

public struct APIWalletAddress: WalletAddressEntity, Codable {
  public var id: String
  public var accountId: String
  public var nickname: String?
  public var address: String
  
  public init(id: String, accountId: String, nickname: String? = nil, address: String) {
    self.id = id
    self.accountId = accountId
    self.nickname = nickname
    self.address = address
  }
}
