import Foundation
import LFRewardDashboard
import DashboardComponents
import LFTransaction
import LFUtilities
import Factory
import LFSolidBank
import SwiftUI
import LFRewards

final class NavigationContainer {
  
  @LazyInjected(\.transactionNavigation) var transactionNavigation
  @LazyInjected(\.rewardNavigation) var rewardNavigation
  
  @MainActor
  func registerModuleNavigation() {
    let container = DIContainerAnyView()
    registerTransactionModuleNavigation(container: container)
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
  
}
