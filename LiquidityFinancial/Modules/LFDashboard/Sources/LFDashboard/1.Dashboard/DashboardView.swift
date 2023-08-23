import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct DashboardView: View {
  @StateObject private var viewModel: DashboardViewModel
  
  init(option: TabOption, tabRedirection: @escaping ((TabOption) -> Void)) {
    _viewModel = .init(
      wrappedValue: DashboardViewModel(option: option, tabRedirection: tabRedirection)
    )
  }
  
  var body: some View {
    Group {
      switch viewModel.option {
      case .cash:
        CashView {
          viewModel.handleGuestUser()
        }
      case .rewards:
        RewardTabView()
      case .assets:
        AssetsView()
      case .account:
        AccountsView()
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onAppear {
      viewModel.appearOperations()
    }
  }
}
