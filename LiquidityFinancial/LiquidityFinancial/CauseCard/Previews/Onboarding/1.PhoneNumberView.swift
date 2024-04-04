import SwiftUI
import SolidOnboarding
import LFUtilities
import BaseOnboarding

// MARK: Preview View
#Preview {
  PhoneNumberView(
    viewModel: PhoneNumberViewModel(
      handleOnboardingStep: nil,
      forceLogout: nil,
      setRouteToAccountLocked: nil
    )
  )
  .embedInNavigation()
}
