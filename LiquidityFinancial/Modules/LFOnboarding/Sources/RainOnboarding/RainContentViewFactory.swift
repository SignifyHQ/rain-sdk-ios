import AccountDomain
import BaseOnboarding
import Factory
import LFUtilities
import SwiftUI

// MARK: - DIContainer
extension Container {
  var contentViewFactory: Factory<RainContentViewFactory> {
    self {
      RainContentViewFactory(container: self)
    }
  }
}

// MARK: - RainContentViewFactory
final class RainContentViewFactory {
  let flowCoordinator: OnboardingFlowCoordinatorProtocol
  let baseOnboardingNavigation: OnboardingDestinationObservable
  let accountDataManager: AccountDataStorageProtocol
  
  init(container: Container) {
    baseOnboardingNavigation = container.onboardingDestinationObservable.callAsFunction()
    flowCoordinator = container.rainOnboardingFlowCoordinator.callAsFunction()
    accountDataManager = container.accountDataManager.callAsFunction()
  }
}

// MARK: - Internal View Components
extension RainContentViewFactory {
  @MainActor
  func createView(
    type: ViewType
  ) -> some View {
    switch type {
    case .initial:
      AnyView(initialView)
    case .landing:
      AnyView(landingView)
    case .phone:
      AnyView(phoneNumberView)
    case .createWallet:
      AnyView(createPortalWalletView)
    case .setPortalWalletPin:
      AnyView(setPortalWalletPinView)
    case .accountLocked:
      // Unused, will need to remove
      AnyView(accountLockedView)
    case let .welcome(type):
      AnyView(welcomeView(type: type))
    case .accountInReview:
      AnyView(accountInReviewView)
    case .accountReject:
      AnyView(accountRejectView)
    case .recoverWallet:
      AnyView(recoverWalletView)
    case .missingInformation:
      // Handled as rejected for now, will update
      AnyView(missingInformationView)
    case .identifyVerification:
      AnyView(identifyVerificationView)
    case .unclear(let message):
      AnyView(unclearView(message: message))
    case .forceUpdate(let model):
      // Not used now, but will be in the future
      AnyView(forceUpdateView(model: model))
    case .acceptTerms:
      AnyView(acceptTermsView)
    case .residentialAddress:
      AnyView(residentialAddressView)
    }
  }
}

// MARK: - Private View Components
private extension RainContentViewFactory {
  @MainActor
  var initialView: some View {
    InitialView()
  }
  
  @MainActor
  var landingView: some View {
    LandingView(
      viewModel: LandingViewModel()
    )
  }
  
  @MainActor
  func unclearView(message: String) -> some View {
    ReviewStatusView(
      viewModel: ReviewStatusViewModel(
        reviewStatus: .unclear(status: message)
      )
    )
  }
  
  @MainActor
  var accountRejectView: some View {
    ReviewStatusView(
      viewModel: ReviewStatusViewModel(
        reviewStatus: .rejected
      )
    )
  }
  
  @MainActor
  var accountInReviewView: some View {
    ReviewStatusView(
      viewModel: ReviewStatusViewModel(
        reviewStatus: .inReview
      )
    )
  }
  
  @MainActor
  var accountLockedView: some View {
    AccountLockedView(
      viewModel: AccountLockedViewModel(
        setRouteToPhoneNumber: { [weak self] in
          self?.flowCoordinator.set(route: .phone)
        }
      )
    )
  }
  
  @MainActor
  var residentialAddressView: some View {
    ResidentialAddressView(
      viewModel: ResidentialAddressViewModel()
    )
  }
  
  @MainActor
  func welcomeView(type: WelcomeType) -> some View {
    let destinationView = AnyView(welcomeDestinationView(type: type))
    
    switch LFUtilities.target {
    case .DogeCard:
      return AnyView(DogeCardWelcomeView(destination: destinationView))
    default:
      return AnyView(WelcomeView(destinationView: destinationView))
    }
  }
  
  @MainActor
  func welcomeDestinationView(type: WelcomeType) -> some View {
    switch type {
    case .createWallet:
      return AnyView(CreateWalletView())
    case .personalInformation:
      return AnyView(
        PersonalInformationView(
          viewModel: PersonalInformationViewModel(),
          onEnterSSN: { [weak self] in
            guard let self else { return }
            self.baseOnboardingNavigation.personalInformationDestinationView = .enterSSN(
              AnyView(self.enterSSNView)
            )
          }
        )
      )
    }
  }
  
  @MainActor
  var enterSSNView: some View {
    EnterSSNView(
      viewModel: EnterSSNViewModel(),
      onEnterAddress: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.enterSSNDestinationView = .address(
          AnyView(AddressView())
        )
      }
    )
  }
  
  @MainActor
  var phoneNumberView: some View {
    PhoneNumberView(
      viewModel: PhoneNumberViewModel(
        handleOnboardingStep: flowCoordinator.fetchOnboardingMissingSteps,
        forceLogout: flowCoordinator.forceLogout,
        setRouteToAccountLocked: { [weak self] in
          self?.flowCoordinator.set(route: .accountLocked)
        }
      )
    )
  }
  
  @MainActor
  var createPortalWalletView: some View {
    CreatePortalWalletView(
      viewModel: CreatePortalWalletViewModel()
    )
  }
  
  @MainActor
  var setPortalWalletPinView: some View {
    SetRecoveryPinView(
      viewModel: SetRecoveryPinViewModel()
    )
  }
  
  @MainActor
  var acceptTermsView: some View {
    AgreeToCardTermsView(
      viewModel: AgreeToCardTermsViewModel()
    )
  }
  
  @MainActor
  var missingInformationView: some View {
    ReviewStatusView(
      viewModel: ReviewStatusViewModel(
        reviewStatus: .rejected
      )
    )
  }
  
  @MainActor
  var identifyVerificationView: some View {
    KycView(
      viewModel: KycViewModel()
    )
  }
  
  @MainActor
  var recoverWalletView: some View {
    WalletRecoveryView(viewModel: WalletRecoveryViewModel())
  }
  
  @MainActor
  func forceUpdateView(model: FeatureConfigModel) -> some View {
    UpdateAppView(featureConfigModel: model)
  }
}

// MARK: - Types
extension RainContentViewFactory {
  enum ViewType {
    case initial, landing, phone, accountInReview, recoverWallet
    case createWallet
    case setPortalWalletPin
    case accountLocked, accountReject
    case missingInformation, identifyVerification
    case unclear(String)
    case residentialAddress
    case welcome(WelcomeType)
    case forceUpdate(FeatureConfigModel)
    case acceptTerms
  }
  
  enum WelcomeType {
    case createWallet
    case personalInformation
  }
}
