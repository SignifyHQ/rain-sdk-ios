import Foundation

public struct PortalAsset {
  public var token: PortalToken
  public var balance: Double?
  public var walletAddress: String?
  
  public init(
    token: PortalToken,
    balance: Double? = nil,
    walletAddress: String? = nil
  ) {
    self.token = token
    self.balance = balance
    self.walletAddress = walletAddress
  }
}
