import Foundation
import LFUtilities
import LFStyleGuide
import LFLocalizable
import SwiftUI
import BaseOnboarding
import Factory
import AccountDomain
import UIComponents
import LFRewards

extension Container {
  var contenViewFactory: ParameterFactory<(EnvironmentManager), SolidContentViewFactory> {
    self { environment in
      SolidContentViewFactory(container: self, environment: environment)
    }
  }
}

final class SolidContentViewFactory {
  enum ViewType {
    case initial
    case phone
    case accountLocked
    case selecteReward
    case kycReview
    case dashboard
    case information
    case accountReject
    case unclear(String)
  }
  
  let environmentManager: EnvironmentManager
  let flowCoordinator: SolidOnboardingFlowCoordinatorProtocol
  let baseOnboardingNavigation: BaseOnboardingDestinationObservable
  let accountDataManager: AccountDataStorageProtocol
  
  init(
    container: Container,
    environment: EnvironmentManager
  ) {
    baseOnboardingNavigation = container.baseOnboardingDestinationObservable.callAsFunction()
    flowCoordinator = container.solidOnboardingFlowCoordinator.callAsFunction()
    accountDataManager = container.accountDataManager.callAsFunction()
    environmentManager = environment
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
    case .information:
      return AnyView(informationView)
    case .accountReject:
      return AnyView(accountRejectView)
    case .unclear(let message):
      return AnyView(unclearView(message: message))
    }
  }
}

private extension SolidContentViewFactory {
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
    AccountLockedView(viewModel: AccountLockedViewModel())
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
      },
      onEnterPassport: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.enterSSNDestinationView = .enterPassport(AnyView(self.enterPassportView))
      })
  }
  
  @MainActor
  var enterPassportView: some View {
    EnterPassportView(
      viewModel: EnterPassportViewModel(),
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
      viewModel: PhoneNumberViewModel(coordinator: baseOnboardingNavigation)
    )
    .environmentObject(environmentManager)
  }
}
