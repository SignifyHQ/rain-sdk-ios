import Foundation
import LFUtilities
import LFStyleGuide
import LFLocalizable
import SwiftUI
import BaseOnboarding
import Factory
import AccountDomain
import LFRewards
import LFAuthentication

extension Container {
  var contenViewFactory: Factory<SolidContentViewFactory> {
    self {
      SolidContentViewFactory(container: self)
    }.cached
  }
}

final class SolidContentViewFactory {
  enum ViewType {
    case initial
    case phone
    case accountLocked
    case selecteReward
    case createPassword
    case kycReview
    case dashboard
    case yourAccount
    case information
    case accountReject
    case unclear(String)
    case forceUpdate(FeatureConfigModel)
  }
  
  let flowCoordinator: SolidOnboardingFlowCoordinatorProtocol
  let baseOnboardingNavigation: OnboardingDestinationObservable
  let accountDataManager: AccountDataStorageProtocol
  
  init(
    container: Container
  ) {
    baseOnboardingNavigation = container.onboardingDestinationObservable.callAsFunction()
    flowCoordinator = container.solidOnboardingFlowCoordinator.callAsFunction()
    accountDataManager = container.accountDataManager.callAsFunction()
  }
  
  @MainActor
  func createView(type: ViewType) -> some View {
    switch type {
    case .initial:
      return AnyView(initialView)
    case .phone:
      return AnyView(phoneNumberView)
    case .accountLocked:
      return AnyView(accountLockedView)
    case .selecteReward:
      return AnyView(selectRewardsView)
    case .kycReview:
      return AnyView(kycReviewView)
    case .dashboard:
      return AnyView(EmptyView())
    case .yourAccount:
      return AnyView(YourAccountView())
    case .information:
      return AnyView(informationView)
    case .accountReject:
      return AnyView(accountRejectView)
    case .unclear(let message):
      return AnyView(unclearView(message: message))
    case .forceUpdate(let model):
      return AnyView(forceUpdateView(model: model))
    case .createPassword:
      return AnyView(createPasswordView)
    }
  }
}

private extension SolidContentViewFactory {
  @MainActor
  var createPasswordView: some View {
    CreatePasswordView(
      purpose: .createNewUser,
      onActionContinue: { [weak self] in
        guard let self else { return }
        flowCoordinator.set(route: .selecteReward)
      })
  }
  
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
  var selectRewardsView: some View {
    SelectRewardsView()
  }
  
  @MainActor
  var enterSSNView: some View {
    EnterSSNView(
      viewModel: EnterSSNViewModel(isVerifySSN: true),
      onEnterAddress: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.enterSSNDestinationView = .address(AnyView(self.addressView))
      })
  }
  
  @MainActor
  var addressView: some View {
    AddressView()
  }
  
  @MainActor
  var yourAccountView: some View {
    YourAccountView()
  }
  
  @MainActor
  var informationView: some View {
    PersonalInformationView(
      viewModel: PersonalInformationViewModel(),
      onEnterSSN: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.personalInformationDestinationView = .enterSSN(AnyView(self.enterSSNView))
      }
    )
  }
  
  @MainActor
  var phoneNumberView: some View {
    PhoneNumberView(
      viewModel: PhoneNumberViewModel(
        handleOnboardingStep: flowCoordinator.handleOnboardingStep,
        forceLogout: flowCoordinator.forceLogout,
        setRouteToAccountLocked: { [weak self] in
          self?.flowCoordinator.set(route: .accountLocked)
        },
        setRouteToPopTimeUp: nil
      )
    )
  }
  
  @MainActor
  func forceUpdateView(model: FeatureConfigModel) -> some View {
    UpdateAppView(featureConfigModel: model)
  }
}
