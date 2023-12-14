import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFTransaction
import LFRewards
import Services

struct RewardsView: View {
  @StateObject private var viewModel: RewardViewModel
  @State private var screenSize: CGSize = .zero
  
  private var emptySpaceHeight: CGFloat {
    // (main height - item height) / 2
    max(20, screenSize.height / 2 - 200)
  }
  
  init(viewModel: RewardViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.onAppear()
      }
      .refreshable {
        viewModel.refresh()
      }
      .readGeometry { geo in
        screenSize = geo.size
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .transactions:
          TransactionListView(
            type: .cashback,
            currencyType: viewModel.currencyType,
            accountID: viewModel.fiatAccountID,
            transactionTypes: Constants.TransactionTypesRequest.rewardCashBack.types
          )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            accountID: viewModel.fiatAccountID,
            transactionId: transaction.id,
            kind: .cashback,
            isPopToRoot: false
          )
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
        if item == .cashBack {
          Text(LFLocalizable.UserRewardType.Cashback.description)
            .font(Fonts.regular.swiftUIFont(size: 12))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        } else {
          Text(item.subtitle(param: 0.75) ?? "")
            .font(Fonts.regular.swiftUIFont(size: 12))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        }
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
  
  var emptyView: some View {
    VStack(alignment: .center, spacing: 12) {
      Spacer(minLength: emptySpaceHeight)
      GenImages.Images.emptyRewards.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.horizontal, 40)
      Text(LFLocalizable.RewardTabView.noRewards)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer(minLength: emptySpaceHeight)
    }
  }
  
  private func transactions(_ items: [TransactionModel]) -> some View {
    Group {
      if items.isEmpty {
        emptyView
      } else {
        LazyVStack(alignment: .leading, spacing: 10) {
          HStack(alignment: .bottom) {
            Text(LFLocalizable.Cashback.latest)
            Spacer()
            seeAllTransactions
              .opacity(items.isEmpty ? 0 : 1)
          }
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          ForEach(items) { transaction in
            TransactionRowView(item: transaction) {
              viewModel.transactionItemTapped(transaction)
            }
          }
        }
      }
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
