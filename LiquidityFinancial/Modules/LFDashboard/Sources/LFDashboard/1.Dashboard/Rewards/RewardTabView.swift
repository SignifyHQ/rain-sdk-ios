import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFTransaction

struct RewardTabView: View {
  @StateObject private var viewModel = RewardTabViewModel()

  var body: some View {
    content
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .changeReward(assetModels, selectedAssetModel):
          ChangeRewardView(
            assetModels: assetModels,
            selectedAssetModel: selectedAssetModel
          )
        case .transactions:
          TransactionListView(
            type: .crypto,
            currencyType: viewModel.currencyType,
            accountID: viewModel.accountDataManager.cryptoAccountID,
            transactionTypes: Constants.TransactionTypesRequest.rewardCryptoBack.types
          )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            accountID: viewModel.accountDataManager.cryptoAccountID,
            transactionId: transaction.id,
            kind: transaction.detailType,
            isPopToRoot: false
          )
        }
      }
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.refreshData()
      }
  }
}

// MARK: - View Components
private extension RewardTabView {
  var content: some View {
    GeometryReader { geo in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 10) {
          if viewModel.isLoading {
            loading
          } else {
            headerView
            activity(size: geo.size)
          }
          Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 30)
      }
    }
  }
  
  private var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 30, height: 25)
        .padding(.top, 20)
    }
    .frame(maxWidth: .infinity)
  }
  
  @ViewBuilder var headerView: some View {
    if let assetType = viewModel.assetModel?.type {
      Button {
        viewModel.onClickedChangeReward()
      } label: {
        HStack(alignment: .top, spacing: 12) {
          HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .center) {
              Circle()
                .fill(Colors.background.swiftUIColor)
                .frame(width: 64, height: 64)
              assetType.image
            }
            VStack(alignment: .leading, spacing: 4) {
              Text(assetType.title.uppercased())
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
                .foregroundColor(Colors.label.swiftUIColor)
              Text(LFLocalizable.RewardTabView.EarningRewards.description(assetType.title.uppercased()))
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            }
          }
          Spacer()
          GenImages.CommonImages.icGear.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
        .padding(.all, 12)
        .background(Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(10)
      }
      .frame(height: 88)
    }
  }
  
  func activity(size: CGSize) -> some View {
    Group {
      switch viewModel.activity {
      case .loading:
        LottieView(loading: .mix)
          .frame(width: 30, height: 20)
          .padding(.top, 8)
      case .transactions:
        transactionsView(size: size)
      case .failure:
        EmptyView()
      }
    }
  }
  
  func transactionsView(size: CGSize) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .bottom) {
        Text(LFLocalizable.RewardTabView.lastestRewards)
        Spacer()
        seeAllTransactions
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      if viewModel.transactions.isEmpty {
        noTransactionsYetView(height: size.height)
      } else {
        ForEach(viewModel.transactions) { transaction in
          TransactionRowView(item: transaction) {
            viewModel.transactionItemTapped(transaction)
          }
        }
      }
    }
  }
    
  func noTransactionsYetView(height: CGFloat) -> some View {
    HStack {
      Spacer()
      VStack(spacing: 8) {
        GenImages.CommonImages.icSearch.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        Text(LFLocalizable.CashTab.NoTransactionYet.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      Spacer()
    }
    .frame(height: height * 0.5)
  }
  
  var seeAllTransactions: some View {
    Button {
      viewModel.onClickedSeeAllButton()
    } label: {
      HStack(spacing: 8) {
        Text(LFLocalizable.RewardTabView.seeAll)
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .frame(height: 30, alignment: .bottom)
    }
  }
}
