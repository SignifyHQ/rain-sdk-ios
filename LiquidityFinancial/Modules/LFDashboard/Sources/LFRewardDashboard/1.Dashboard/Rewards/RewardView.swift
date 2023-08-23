import SwiftUI

struct RewardsView: View {
  @StateObject private var viewModel: RewardViewModel
  
  init(viewModel: RewardViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    Group {
      switch viewModel.type {
      case .donation:
        DonationsView(viewModel: .init(tabRedirection: viewModel.tabRedirection))
      case .cashBack:
        CashbackView(viewModel: .init())
      default:
        EmptyView()
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
}
