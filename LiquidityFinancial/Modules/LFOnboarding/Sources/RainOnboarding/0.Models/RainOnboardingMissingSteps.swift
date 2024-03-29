import Foundation
import RainDomain

enum RainOnboardingMissingSteps: String {
  case createPortalWallet = "create_wallet_portal"
  case createRainUser = "create_rain_user"
  case needInformation = "rain_user_need_information"
  case needVerification = "rain_user_need_verification"
}
