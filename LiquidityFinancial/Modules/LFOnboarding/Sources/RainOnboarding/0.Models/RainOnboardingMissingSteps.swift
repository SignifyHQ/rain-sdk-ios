import Foundation
import RainDomain

enum RainOnboardingMissingSteps: String {
  case createPortalWallet = "portal_create_wallet"
  case createRainUser = "rain_create_user"
  case needInformation = "rain_user_needs_information"
  case needVerification = "rain_user_needs_verification"
}
