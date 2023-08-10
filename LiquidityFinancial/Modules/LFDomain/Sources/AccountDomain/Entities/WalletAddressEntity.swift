import Foundation

public protocol WalletAddressEntity {
  var id: String { get }
  var accountId: String { get }
  var nickname: String? { get }
  var address: String { get }
  
  init(id: String, accountId: String, nickname: String?, address: String)
}
