import Foundation
import LFDashboard
import BaseDashboard
import LFTransaction
import LFUtilities
import Factory
import LFNetspendBank
import SwiftUI
import NoBankOnboarding

final class NavigationContainer {
  
  @LazyInjected(\.transactionNavigation) var transactionNavigation
  @LazyInjected(\.rewardNavigation) var rewardNavigation
  @LazyInjected(\.dashboardNavigation) var dashboardNavigation
  
  @MainActor
  func registerModuleNavigation() {
    let container = DIContainerAnyView()
    registerTransactionModuleNavigation(container: container)
    
    registerDashboardModuleNavigation(container: container)
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
    
    transactionNavigation.registerDisputeTransactionView(type: NetspendDisputeTransactionViewController.self) { [weak dashboardNavigation] _ in
      guard let parameters = dashboardNavigation?.disputeTransactionParameters else {
        return AnyView(EmptyView())
      }
      return AnyView(
        NetspendDisputeTransactionViewController(
          netspendAccountID: parameters.id,
          passcode: parameters.passcode,
          onClose: parameters.onClose
        )
      )
    }
  }
  
  @MainActor
  func registerDashboardModuleNavigation(container: DIContainerAnyView) {
    dashboardNavigation.setup(container: container)
    
    dashboardNavigation.registerDisputeTransactionView(type: NetspendDisputeTransactionViewController.self) { [weak dashboardNavigation] _ in
      guard let parameters = dashboardNavigation?.disputeTransactionParameters else {
        return AnyView(EmptyView())
      }
      return AnyView(
        NetspendDisputeTransactionViewController(
          netspendAccountID: parameters.id,
          passcode: parameters.passcode,
          onClose: parameters.onClose
        )
      )
    }
  }
  
}
