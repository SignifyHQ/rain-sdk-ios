import AccountDomain
import Foundation

public struct APIPasswordResetToken: PasswordResetTokenEntity, Codable {
  public var token: String
}
