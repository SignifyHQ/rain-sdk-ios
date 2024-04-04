import SwiftUI
import SolidOnboarding
import BaseOnboarding

// MARK: Preview View
#Preview {
  IdentityVerificationCodeView(
    viewModel: IdentityVerificationCodeViewModel(
      phoneNumber: "",
      otpCode: "",
      kind: .ssn,
      handleOnboardingStep: nil,
      forceLogout: nil,
      setRouteToAccountLocked: nil
    )
  )
}
