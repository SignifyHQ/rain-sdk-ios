import Foundation

enum RainOnboardingMissingSteps: String {
  case createPortalWallet = "portal_create_wallet"
  case setPortalWalletPin = "wallet_setup_backup_pin"
  case createRainUser = "rain_create_user"
  case needsInformation = "rain_user_needs_information"
  case needsVerification = "rain_user_needs_verification"
  case acceptTerms = "accept_terms"
  case blocked = "rain_blocked"
}
