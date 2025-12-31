import Foundation

public enum OnboardingNavigation {
  case createPortalWallet
  case setPortalWalletPin
  case recoverPortalWallet
  case createRainUser
  case informationRequired
  case verificationRequired
  case acceptTerms
  case accountRejected
  case accountInReview
  case unclearStatus(String)
}
