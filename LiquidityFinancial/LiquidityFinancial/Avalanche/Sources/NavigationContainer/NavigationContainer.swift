import Foundation
import LFDashboard
import BaseDashboard
import LFTransaction
import LFUtilities
import Factory
import LFBank
import SwiftUI
import LFRewards
import LFAccountOnboarding

final class NavigationContainer {
  
  @LazyInjected(\.transactionNavigation) var transactionNavigation
  @LazyInjected(\.rewardNavigation) var rewardNavigation
  
  @MainActor
  func registerModuleNavigation() {
    let container = DIContainerAnyView()
    registerTransactionModuleNavigation(container: container)
    
    registerRewardModuleNavigation(container: container)
  }
  
  @MainActor
  func registerTransactionModuleNavigation(container: DIContainerAnyView) {
    transactionNavigation.setup(container: container)
    
    transactionNavigation.registerCurrentReward(type: CurrentRewardView.self) { _ in
      AnyView(CurrentRewardView())
    }
    
    transactionNavigation.registerAddBankDebit(type: AddBankWithDebitView.self) { _ in
      AnyView(AddBankWithDebitView())
    }
  }
  
  @MainActor
  func registerRewardModuleNavigation(container: DIContainerAnyView) {
    rewardNavigation.setup(container: container)
    
    rewardNavigation.registerAgreementView(type: AgreementView.self) { _ in
      AnyView(AgreementView(viewModel: AgreementViewModel()))
    }
  }
  
}
