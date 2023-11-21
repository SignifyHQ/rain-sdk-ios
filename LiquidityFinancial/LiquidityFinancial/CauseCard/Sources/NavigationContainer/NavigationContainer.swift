import Foundation
import LFRewardDashboard
import BaseDashboard
import LFTransaction
import LFUtilities
import Factory
import LFSolidBank
import SwiftUI
import LFRewards

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
    
    transactionNavigation.registerDisputeTransactionView(type: EmptyView.self) { _ in
      AnyView(EmptyView())
    }
  }
  
  @MainActor
  func registerDashboardModuleNavigation(container: DIContainerAnyView) {
    dashboardNavigation.setup(container: container)
    
    dashboardNavigation.registerDisputeTransactionView(type: EmptyView.self) { _ in
      AnyView(EmptyView())
    }
  }
  
}
