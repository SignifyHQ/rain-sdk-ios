import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFTransaction
import LFNetspendBank
import Services
import DashboardComponents

struct RewardTabView: View {
  @StateObject
  private var viewModel: RewardTabViewModel
  
  init(viewModel: RewardTabViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .changeReward(selectedRewardCurrency):
          ChangeRewardView(
            availableCurrencies: viewModel.availableRewardCurrencies,
            selectedRewardCurrency: selectedRewardCurrency
          )
        case let .transactions(isCrypto):
          TransactionListView(
            type: isCrypto ? .crypto : .cashback,
            currencyType: viewModel.currencyType,
            accountID: viewModel.accountID,
            transactionTypes: viewModel.transactionTypes
          )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            accountID: viewModel.accountID,
            transactionId: transaction.id,
            kind: transaction.detailType,
            isPopToRoot: false
          )
        }
      }
      .background(Colors.background.swiftUIColor)
      .refreshable {
        viewModel.fetchAllTransactions()
      }
  }
}

// MARK: - View Components
private extension RewardTabView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 10) {
        if viewModel.isLoading {
          loading
        } else if viewModel.selectedRewardCurrency == nil {
          selectTypeView
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
  
  private var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 30, height: 25)
        .padding(.top, 20)
    }
    .frame(maxWidth: .infinity)
  }
  
  @ViewBuilder var headerView: some View {
    if let assetType = viewModel.selectedRewardCurrency {
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
        if viewModel.transactions.isEmpty {
          emptyView
        } else {
          ShortTransactionsView(
            transactions: $viewModel.transactions,
            title: LFLocalizable.RewardTabView.lastestRewards,
            onTapTransactionCell: viewModel.transactionItemTapped,
            seeAllAction: {
              viewModel.onClickedSeeAllButton()
            }
          )
        }
      case .failure:
        EmptyView()
      }
    }
  }
  
  var emptyView: some View {
    HStack(alignment: .center) {
      VStack(alignment: .center, spacing: 12) {
        Spacer(minLength: 120)
        GenImages.Images.emptyRewards.swiftUIImage
        Text(LFLocalizable.RewardTabView.noRewards)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer(minLength: 120)
      }
      .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var selectTypeView: some View {
    ZStack(alignment: .top) {
      selectTypeContentView
      GenImages.Images.rewardHeader.swiftUIImage
        .offset(y: -74)
    }
    .offset(y: 74)
  }
  
  var selectTypeContentView: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.RewardTabView.FirstReward.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer().frame(height: 16)
      VStack(spacing: 12) {
        ForEach(viewModel.availableRewardCurrencies, id: \.self) { asset in
          assetCell(assetType: asset)
        }
      }
      Spacer().frame(height: 16)
      FullSizeButton(
        title: LFLocalizable.RewardTabView.FirstReward.select,
        isDisable: false
      ) {
        viewModel.onClickedChangeReward()
      }
    }
    .padding([.horizontal, .bottom], 16)
    .padding(.top, 120)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  @ViewBuilder func assetCell(assetType: AssetType) -> some View {
    HStack(spacing: 8) {
      assetType.image
      Text(assetType.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      Spacer()
    }
    .frame(height: 24)
  }
}
