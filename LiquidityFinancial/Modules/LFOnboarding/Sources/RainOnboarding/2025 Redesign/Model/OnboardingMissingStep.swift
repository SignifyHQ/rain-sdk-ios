import Foundation

enum OnboardingMissingStep: String {
  case shouldCreatePortalWallet = "portal_create_wallet"
  case shouldSetPortalWalletPin = "wallet_setup_backup_pin"
  case shouldCreateRainUser = "rain_create_user"
  case informationRequired = "rain_user_needs_information"
  case verificationRequired = "rain_user_needs_verification"
  case shouldAcceptTerms = "accept_terms"
  case isBlocked = "rain_blocked"
}
