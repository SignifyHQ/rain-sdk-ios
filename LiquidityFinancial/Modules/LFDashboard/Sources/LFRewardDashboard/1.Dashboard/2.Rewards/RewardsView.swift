import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFTransaction
import LFRewards

struct RewardsView: View {
  @StateObject private var viewModel: RewardViewModel
  
  init(viewModel: RewardViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.refresh()
      }
      .refreshable {
        viewModel.refresh()
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .transactions:
          TransactionListView(
            type: .cashback,
            currencyType: viewModel.currencyType,
            accountID: viewModel.account?.id ?? .empty,
            transactionTypes: Constants.TransactionTypesRequest.fiat.types
          )
        }
      }
      .sheet(item: $viewModel.sheet) { sheet in
        switch sheet {
        case let .transactionDetail(transaction):
          TransactionDetailView(accountID: viewModel.account?.id ?? .empty, transactionId: transaction.id, kind: .cashback)
            .embedInNavigation()
        }
      }
  }
  
  private var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 12) {
        header
        feed
        Spacer()
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 30)
    }
  }
  
  private var header: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(Colors.background.swiftUIColor)
          .frame(64)
        if let image = item.image {
          image
            .resizable()
            .frame(38)
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(item.title ?? "")
          .font(Fonts.regular.swiftUIFont(size: 16))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(item.subtitle(param: 0.75) ?? "")
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      
      Spacer()
    }
    .padding(16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  private var item: UserRewardType {
    .cashBack
  }
  
  private var feed: some View {
    Group {
      switch viewModel.feed {
      case .idle, .failure:
        transactions([])
      case .loading:
        LottieView(loading: .mix)
          .frame(width: 30, height: 20)
      case let .success(items):
        transactions(items)
      }
    }
  }
  
  private func transactions(_ items: [TransactionModel]) -> some View {
    LazyVStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .bottom) {
        Text(LFLocalizable.Cashback.latest)
        Spacer()
        seeAllTransactions
          .opacity(viewModel.transactions.isEmpty ? 0 : 1)
      }
      .font(Fonts.regular.swiftUIFont(size: 12))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      ForEach(items) { transaction in
        TransactionRowView(item: transaction) {
          viewModel.transactionItemTapped(transaction)
        }
      }
    }
    .overlay {
      EmptyListView(text: LFLocalizable.Rewards.noRewards)
        .opacity(items.isEmpty ? 1 : 0)
        .offset(y: 200)
    }
  }
  
  private var seeAllTransactions: some View {
    Button {
      viewModel.seeAllTransactionsTapped()
    } label: {
      HStack(spacing: 8) {
        Text(LFLocalizable.Cashback.seeAll)
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .frame(height: 30, alignment: .bottom)
    }
  }
}

#if DEBUG

  // MARK: - SelectRewardsView_Previews

struct CashbackView_Previews: PreviewProvider {
  static var previews: some View {
    RewardsView(viewModel: .init())
      .embedInNavigation()
  }
}

#endif
