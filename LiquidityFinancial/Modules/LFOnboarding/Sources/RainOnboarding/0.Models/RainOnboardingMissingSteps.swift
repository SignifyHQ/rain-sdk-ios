import Foundation

enum RainOnboardingMissingSteps: String {
  case createPortalWallet = "portal_create_wallet"
  case createRainUser = "rain_create_user"
  case needsInformation = "rain_user_needs_information"
  case needsVerification = "rain_user_needs_verification"
}
