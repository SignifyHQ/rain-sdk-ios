import AccountDomain

public struct APIDisableMFA: Decodable, DisableMFAEntity {
  public let success: Bool
}
