import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import RainFeature
import RainOnboarding
import Services
import GeneralFeature

struct CashView: View {
  @Environment(\.scenePhase) var scenePhase
  @StateObject private var viewModel: CashViewModel
  @State private var isNotLinkedCard = false
  
  let listCardViewModel: RainListCardsViewModel
  
  init(viewModel: CashViewModel, listCardViewModel: RainListCardsViewModel) {
    _viewModel = .init(
      wrappedValue: viewModel
    )
    self.listCardViewModel = listCardViewModel
  }
  
  var body: some View {
    Group {
      if viewModel.isCardActive {
        activeView
          .disabled(viewModel.isDisableView)
      } else {
        ErrorView(message: L10N.Common.CashTab.DeActiveError.message)
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .track(name: String(describing: type(of: self)))
    .background(Colors.background.swiftUIColor)
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .changeAsset:
        ChangeAssetView(
          selectedAsset: $viewModel.selectedAsset,
          balance: viewModel.cashBalanceValue,
          assets: viewModel.assets
        )
      case .transactions:
        TransactionListView(
          filterType: .account,
          currencyType: viewModel.currencyType,
          transactionTypes: Constants.TransactionTypesRequest.fiat.types
        )
      case let .moveMoney(kind):
        MoveMoneyAccountView(kind: kind)
      case let .transactionDetail(transaction):
        TransactionDetailView(
          method: .transactionID(transaction.id),
          kind: transaction.detailType,
          isPopToRoot: false
        )
      case let .addToBalance(asset):
        MoveCryptoInputView(type: .sendCollateral, assetModel: asset)
      case let .enterWithdrawalAmount(address, assetCollateral):
        MoveCryptoInputView(
          type: .withdrawCollateral(address: address, nickname: nil),
          assetModel: assetCollateral,
          completeAction: {
            viewModel.navigation = nil
          }
        )
      case let .enterWalletAddress(assetCollateral):
        EnterWalletAddressView(
          viewModel: EnterWalletAddressViewModel(asset: assetCollateral, kind: .withdrawCollateral)
        ) {
          viewModel.navigation = nil
        }
      }
    }
    .fullScreenCover(item: $viewModel.fullScreen) { item in
      switch item {
      case .fundCard(let kind):
        FundCardView(kind: kind) {
          viewModel.fullScreen = nil
        }
        .embedInNavigation()
      }
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .background {
        viewModel.shouldReloadListTransaction = true
      }
      if newValue == .active && viewModel.shouldReloadListTransaction {
        viewModel.shouldReloadListTransaction = false
        viewModel.onRefresh()
      }
    })
  }
}

private extension CashView {
  var changeAssetButton: some View {
    HStack(spacing: 8) {
      viewModel.selectedAsset.image
      Text(viewModel.selectedAsset.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      Spacer()
      Button {
        viewModel.onClickedChangeAssetButton()
      } label: {
        CircleButton(style: .right)
          .frame(32)
      }
    }
    .padding(.leading, 16)
    .padding(.trailing, 12)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
  }
  
  var activeView: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 16) {
        CashCardView(
          isNoLinkedCard: $isNotLinkedCard,
          isPOFlow: true, // !userManager.isGuest
          showLoadingIndicator: viewModel.isLoading,
          cashBalance: viewModel.cashBalanceValue,
          assetType: viewModel.selectedAsset,
          listCardViewModel: listCardViewModel
        ) {
          viewModel.guestCardTapped()
        }
        // (Volo): Hide deposit button since banking features are not supported currently
        //        .overlay(alignment: .bottom) {
        //          depositButton
        //        }
        // changeAssetButton TODO: Remove for MVP
        //        BalanceAlertView(
        //          type: .cash,
        //          hasContacts: !viewModel.linkedAccount.isEmpty,
        //          cashBalance: viewModel.cashBalanceValue
        //        ) {
        //          viewModel.addMoneyTapped()
        //        }
        VStack(spacing: 8) {
          addToBalanceButton
          withdrawalBalanceButton
        }
        activity
      }
      .padding(.horizontal, 30)
      .padding(.top, 20)
      .padding(.bottom, 12)
    }
    .blur(radius: viewModel.showWithdrawalBalanceSheet ? 16 : 0)
    .sheet(isPresented: $viewModel.showWithdrawalBalanceSheet) {
      WithdrawBalanceSheet(
        assetTitle: viewModel.collateralAsset?.type?.title ?? .empty
      ) { type in
        viewModel.walletTypeButtonTapped(type: type)
      }
    }
    .refreshable {
      viewModel.onRefresh()
    }
  }
  
  @ViewBuilder var depositButton: some View {
    if viewModel.transactions.isEmpty && viewModel.activity != .loading && !isNotLinkedCard {
      Button {
        viewModel.addMoneyTapped()
      } label: {
        Text(L10N.Common.CashTab.Deposit.title)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.whiteText.swiftUIColor)
      }
      .frame(width: 80, height: 28)
      .background(Colors.darkBackground.swiftUIColor.cornerRadius(8))
      .padding(.bottom, 8)
    }
  }
  
  var activity: some View {
    Group {
      switch viewModel.activity {
      case .loading:
        LottieView(loading: .mix)
          .frame(width: 30, height: 20)
          .padding(.top, 8)
      default:
        ShortTransactionsView(
          transactions: $viewModel.transactions,
          title: L10N.Common.CashTab.LastestTransaction.title,
          onTapTransactionCell: viewModel.transactionItemTapped,
          seeAllAction: {
            viewModel.onClickedSeeAllButton()
          }
        )
      }
    }
  }
  
  var addFundsView: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(L10N.Common.CashTab.WaysToAdd.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .padding(.top, 16)
      AddFundsView(
        viewModel: viewModel.addFundsViewModel,
        achInformation: $viewModel.achInformation,
        isDisableView: $viewModel.isDisableView
      )
    }
  }
  
  var addToBalanceButton: some View {
    FullSizeButton(title: L10N.Common.CashTab.AddToBalance.title, isDisable: false, type: .secondary) {
      viewModel.addToBalanceButtonTapped()
    }
  }
  
  var withdrawalBalanceButton: some View {
    FullSizeButton(title: L10N.Common.CashTab.WithdrawBalance.title, isDisable: false, type: .secondary) {
      viewModel.withdrawBalanceButtonTapped()
    }
  }
}
