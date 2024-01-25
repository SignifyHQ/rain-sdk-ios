import Foundation

public enum VerificationType: String {
  case last4X = "LAST_4_X"
  case recoveryCode = "RECOVERY_CODE"
  case password = "PASSWORD"
  case totp = "TOTP"
}
