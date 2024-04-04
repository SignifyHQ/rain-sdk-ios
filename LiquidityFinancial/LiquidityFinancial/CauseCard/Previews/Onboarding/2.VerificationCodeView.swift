import SwiftUI
import SolidOnboarding
import BaseOnboarding

// MARK: Preview View
#Preview {
  VerificationCodeView(
    viewModel: VerificationCodeViewModel(
      phoneNumber: "+19999999999",
      requireAuth: [],
      handleOnboardingStep: nil,
      forceLogout: nil,
      setRouteToAccountLocked: nil
    )
  )
}
