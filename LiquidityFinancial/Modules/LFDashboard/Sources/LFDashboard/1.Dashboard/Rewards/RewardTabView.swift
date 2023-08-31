import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFTransaction

struct RewardTabView: View {
  @StateObject private var viewModel: RewardTabViewModel
  var onRefresh: (() -> Void)?
  init(viewModel: RewardTabViewModel, onRefresh: (() -> Void)? = nil) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onRefresh = onRefresh
  }
  
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
        Task { @MainActor in
          await viewModel.apiLoadTransactions()
        }
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
            activity
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
  
  var activity: some View {
    Group {
      switch viewModel.activity {
      case .loading:
        LottieView(loading: .mix)
          .frame(width: 30, height: 20)
          .padding(.top, 8)
      case .transactions:
        ShortTransactionsView(
          transactions: $viewModel.transactions,
          title: LFLocalizable.RewardTabView.lastestRewards,
          onTapTransactionCell: viewModel.transactionItemTapped,
          seeAllAction: {
            viewModel.onClickedSeeAllButton()
          }
        )
      case .failure:
        EmptyView()
      }
    }
  }
}
