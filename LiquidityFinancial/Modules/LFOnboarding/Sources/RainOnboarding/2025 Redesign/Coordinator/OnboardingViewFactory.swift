import Factory
import Foundation
import SwiftUI

// MARK: - Dependency Injection
extension Container {
  public var onboardingViewFactory: Factory<OnboardingViewFactoryProtocol> {
    self {
      OnboardingViewFactory()
    }
    .singleton
  }
}

// MARK: - OnboardingViewFactoryProtocol
public protocol OnboardingViewFactoryProtocol {
  func createView(
    for navigation: OnboardingNavigation
  ) -> AnyView
}

public class OnboardingViewFactory: @preconcurrency OnboardingViewFactoryProtocol {
  @MainActor
  public func createView(
    for navigation: OnboardingNavigation
  ) -> AnyView {
    switch navigation {
    case .createPortalWallet:
      return AnyView(
        CreatePortalWalletView(
          viewModel: CreatePortalWalletViewModel()
        )
      )
    case .setPortalWalletPin:
      return AnyView(
        SetRecoveryPinView(
          viewModel: SetRecoveryPinViewModel()
        )
      )
    case .recoverPortalWallet:
      return AnyView(
        WalletRecoveryView(
          viewModel: WalletRecoveryViewModel()
        )
      )
    case .createRainUser:
      return AnyView(
        ResidentialAddressView(
          viewModel: ResidentialAddressViewModel()
        )
      )
      // Missing information status, handled as rejected for now but will update
    case .informationRequired:
      return AnyView(
        ReviewStatusView(
          viewModel: ReviewStatusViewModel(
            reviewStatus: .rejected
          )
        )
      )
    case .verificationRequired:
      return AnyView(
        KycView(
          viewModel: KycViewModel()
        )
      )
    case .acceptTerms:
      return AnyView(
        AgreeToCardTermsView(
          viewModel: AgreeToCardTermsViewModel()
        )
      )
    case .accountRejected:
      return AnyView(
        ReviewStatusView(
          viewModel: ReviewStatusViewModel(
            reviewStatus: .rejected
          )
        )
      )
    case .accountInReview:
      return AnyView(
        ReviewStatusView(
          viewModel: ReviewStatusViewModel(
            reviewStatus: .inReview
          )
        )
      )
    case .unclearStatus(let status):
      return AnyView(
        ReviewStatusView(
          viewModel: ReviewStatusViewModel(
            reviewStatus: .unclear(status: status)
          )
        )
      )
    }
  }
}
