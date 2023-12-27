import AccountDomain

public struct APIEnableMFA: Decodable, EnableMFAEntity {
  public let recoveryCode: String
}
