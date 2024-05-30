import AccountDomain

public struct APIDeleteWalletResponse: DeleteWalletEntity {
  public let success: Bool
  public init(success: Bool) {
    self.success = success
  }
}
