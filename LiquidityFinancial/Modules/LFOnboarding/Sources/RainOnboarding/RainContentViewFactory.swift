import Foundation
import LFUtilities
import LFStyleGuide
import LFLocalizable
import SwiftUI
import Factory
import AccountDomain
import BaseOnboarding
import EnvironmentService

// MARK: - DIContainer
extension Container {
  var contenViewFactory: Factory<RainContentViewFactory> {
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
  func createView(type: ViewType) -> some View {
    switch type {
    case .initial:
      return AnyView(initialView)
    case .phone:
      return AnyView(phoneNumberView)
    case .accountLocked:
      return AnyView(accountLockedView)
    case let .welcome(type):
      return AnyView(welcomeView(type: type))
    case .kycReview:
      return AnyView(kycReviewView)
    case .accountReject:
      return AnyView(accountRejectView)
    case .unclear(let message):
      return AnyView(unclearView(message: message))
    case .forceUpdate(let model):
      return AnyView(forceUpdateView(model: model))
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
  func unclearView(message: String) -> some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .common(message)))
  }
  
  @MainActor
  var accountRejectView: some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .reject))
  }
  
  @MainActor
  var documentInReviewView: some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .documentInReview))
  }
  
  @MainActor
  var kycReviewView: some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .inReview(accountDataManager.userNameDisplay)))
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
      viewModel: EnterSSNViewModel(isVerifySSN: true),
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
  func forceUpdateView(model: FeatureConfigModel) -> some View {
    UpdateAppView(featureConfigModel: model)
  }
}

// MARK: - Types
extension RainContentViewFactory {
  enum ViewType {
    case initial, phone, kycReview
    case accountLocked, accountReject
    case unclear(String)
    case welcome(WelcomeType)
    case forceUpdate(FeatureConfigModel)
  }
  
  enum WelcomeType {
    case createWallet
    case personalInformation
  }
}
