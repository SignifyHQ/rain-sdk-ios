import Foundation
import LFUtilities
import LFStyleGuide
import LFLocalizable
import SwiftUI
import UIComponents
import Factory
import AccountDomain
import UIComponents
import EnvironmentService

extension Container {
  var contenViewFactory: Factory<NSContentViewFactory> {
    self {
      NSContentViewFactory(container: self)
    }
  }
}

final class NSContentViewFactory {
  enum ViewType {
    case initial
    case phone
    case accountLocked
    case forceUpdate(FeatureConfigModel)
    case noBankPopup
  }
  
  let flowCoordinator: OnboardingFlowCoordinatorProtocol
  let baseOnboardingNavigation: OnboardingDestinationObservable
  let accountDataManager: AccountDataStorageProtocol
  
  init(
    container: Container
  ) {
    baseOnboardingNavigation = container.onboardingDestinationObservable.callAsFunction()
    flowCoordinator = container.noBankOnboardingFlowCoordinator.callAsFunction()
    accountDataManager = container.accountDataManager.callAsFunction()
  }
  
  @MainActor
  func createView(type: ViewType) -> some View {
    switch type {
    case .phone:
      return AnyView(phoneNumberView)
    case .accountLocked:
      return AnyView(accountLockedView)
    case .initial:
      return AnyView(initialView)
    case .forceUpdate(let model):
      return AnyView(forceUpdateView(model: model))
    case .noBankPopup:
      return AnyView(blockingFiatView)
    }
  }
}

private extension NSContentViewFactory {
  @MainActor
  var initialView: some View {
    InitialView()
  }
  
  @MainActor
  var accountLockedView: some View {
    AccountLockedView(viewModel: AccountLockedViewModel())
  }
  
  @MainActor
  var phoneNumberView: some View {
    PhoneNumberView(
      viewModel: PhoneNumberViewModel()
    )
  }
  
  @MainActor
  func forceUpdateView(model: FeatureConfigModel) -> some View {
    UpdateAppView(featureConfigModel: model)
  }
  
  @MainActor
  var blockingFiatView: some View {
    BlockingFiatView()
  }
}
