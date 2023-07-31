import Foundation
import AccountDomain

public struct APIZeroHashAccount: ZeroHashAccount, Decodable {
  public var externalAccountId: String?
  public var id: String?
}
