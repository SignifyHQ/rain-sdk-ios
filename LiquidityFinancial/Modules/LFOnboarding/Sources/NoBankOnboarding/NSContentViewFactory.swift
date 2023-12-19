import Foundation
import LFUtilities
import LFStyleGuide
import LFLocalizable
import SwiftUI
import BaseOnboarding
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
    case initial, phone
    case accountLocked
    case forceUpdate(FeatureConfigModel)
    case accountMigration
    case noBankPopup
  }
  
  let flowCoordinator: OnboardingFlowCoordinatorProtocol
  let baseOnboardingNavigation: BaseOnboardingDestinationObservable
  let accountDataManager: AccountDataStorageProtocol
  
  init(
    container: Container
  ) {
    baseOnboardingNavigation = container.baseOnboardingDestinationObservable.callAsFunction()
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
    case .accountMigration:
      return AnyView(accountMigrationView)
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
      viewModel: PhoneNumberViewModel(coordinator: baseOnboardingNavigation)
    )
  }
  
  @MainActor
  func forceUpdateView(model: FeatureConfigModel) -> some View {
    UpdateAppView(featureConfigModel: model)
  }
  
  @MainActor
  var accountMigrationView: some View {
    AccountMigrationView(viewModel: AccountMigrationViewModel())
  }
  
  @MainActor
  var blockingFiatView: some View {
    BlockingFiatView()
  }
}
