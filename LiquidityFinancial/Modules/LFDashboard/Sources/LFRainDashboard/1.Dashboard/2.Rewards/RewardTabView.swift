import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import GeneralFeature

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
        case .transactions:
          TransactionListView(
            filterType: .account,
            currencyType: viewModel.currencyType,
            contractAddress: nil, // TODO: MinhNguyen - Will update it in the ENG-4319 ticket
            transactionTypes: viewModel.transactionTypes
          )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            method: .transactionID(transaction.id),
            kind: transaction.detailType,
            isPopToRoot: false
          )
        case let .enterWithdrawalAmount(address, assetCollateral, balance):
          MoveCryptoInputView(
            type: .withdrawReward(
              address: address,
              nickname: nil,
              balance: balance,
              shouldSaveAddress: false
            ),
            assetModel: assetCollateral,
            completeAction: {
              viewModel.handleRewardWithdrawalSuccessfully()
            }
          )
        case let .enterWalletAddress(assetCollateral, balance):
          EnterWalletAddressView(
            viewModel: EnterWalletAddressViewModel(
              asset: assetCollateral, kind: .withdrawReward(balance: balance)
            )
          ) {
            viewModel.navigation = nil
          }
        }
      }
      .background(Colors.background.swiftUIColor)
      .blur(radius: viewModel.showWithdrawalBalanceSheet ? 16 : 0)
      .sheet(isPresented: $viewModel.showWithdrawalBalanceSheet) {
        WalletOptionBottomSheet(
          title: L10N.Common.RewardTabView.WithdrawBalance.sheetTitle,
          assetTitle: viewModel.collateralAsset?.type?.title ?? .empty
        ) { type in
          viewModel.walletTypeButtonTapped(type: type)
        }
      }
      .refreshable {
        viewModel.fetchAllTransactions()
        viewModel.getRewardBalance()
      }
  }
}

// MARK: - View Components
private extension RewardTabView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 10) {
        headerView
        activity
        Spacer()
      }
      .padding(.top, 20)
      .padding(.horizontal, 30)
    }
  }
  
  var headerView: some View {
    VStack(alignment: .leading, spacing: 16) {
      rewardAssetView(assetType: viewModel.selectedRewardCurrency)
      GenImages.CommonImages.dash.swiftUIImage
        .resizable()
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      VStack(spacing: 8) {
        ForEach(RewardTabViewModel.RewardBalance.allCases, id: \.self) { type in
          rewardBalanceView(assetType: .usdc, type: type)
        }
      }
      GenImages.CommonImages.dash.swiftUIImage
        .resizable()
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      withdrawBalanceButton
    }
    .padding(.all, 12)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  var withdrawBalanceButton: some View {
    FullSizeButton(
      title: L10N.Common.RewardTabView.WithdrawBalance.buttonTitle,
      isDisable: (viewModel.balances[.available] ?? 0) == 0
    ) {
      viewModel.withdrawBalanceButtonTapped()
    }
  }
  
  private func rewardBalanceView(
    assetType: AssetType,
    type: RewardTabViewModel.RewardBalance
  ) -> some View {
    // Always show available balance, show pending only if it is not zero
    let amount: Double = viewModel.balances[type] ?? 0.0
    let shouldShow: Bool = (type == .available || amount != 0)
    
    return Group {
      if shouldShow {
        HStack {
          Text(type.title)
            .font(
              Fonts.regular.swiftUIFont(size: type.fontSize)
            )
            .foregroundColor(type.foregroundColor)
          Spacer()
          Text("\(amount.formattedCryptoAmount()) \(assetType.title)")
            .font(
              Fonts.bold.swiftUIFont(size: type.fontSize)
            )
            .foregroundColor(type.foregroundColor)
        }
      }
    }
  }
    
  func rewardAssetView(assetType: AssetType) -> some View {
    HStack(alignment: .center, spacing: 12) {
      Circle()
        .fill(Colors.background.swiftUIColor)
        .frame(64)
        .overlay {
          assetType.image?.frame(32)
        }
      VStack(alignment: .leading, spacing: 4) {
        Text(assetType.title.uppercased())
          .font(
            Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value)
          )
          .foregroundColor(Colors.label.swiftUIColor)
        Text(L10N.Common.RewardTabView.EarningRewards.description(assetType.title.uppercased()))
          .font(
            Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value)
          )
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      Spacer()
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
            title: L10N.Common.RewardTabView.lastestRewards,
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
        Text(L10N.Common.RewardTabView.noRewards)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer(minLength: 120)
      }
      .fixedSize(horizontal: false, vertical: true)
    }
  }
}
