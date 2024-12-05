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
    activeView
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .track(name: String(describing: type(of: self)))
    .background(Colors.background.swiftUIColor)
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .transactions:
        TransactionListView(
          currencyType: viewModel.currencyType,
          transactionTypes: Constants.TransactionTypesRequest.fiat.types
        )
      case let .transactionDetail(transaction):
        TransactionDetailView(
          method: .transactionID(transaction.id),
          kind: transaction.detailType,
          isPopToRoot: false
        )
      case let .enterDepositAmount(asset):
        MoveCryptoInputView(
          type: .depositCollateral,
          assetModel: asset,
          completeAction: {
            viewModel.navigation = nil
          }
        )
      case let .depositWalletAddress(title, address):
        ReceiveCryptoView(assetTitle: title, walletAddress: address)
      case let .enterWithdrawalAmount(address, assetCollateral):
        MoveCryptoInputView(
          type: .withdrawCollateral(address: address, nickname: nil, shouldSaveAddress: false),
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
  var activeView: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 16) {
        CashCardView(
          isNoLinkedCard: $isNotLinkedCard,
          isPOFlow: true,
          showLoadingIndicator: viewModel.isLoading,
          cashBalance: viewModel.cashBalanceValue,
          assetType: viewModel.selectedAsset,
          listCardViewModel: listCardViewModel
        ) {
        }

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
    .blur(radius: viewModel.bottomSheet != nil ? 16 : 0)
    .sheet(item: $viewModel.bottomSheet) { sheet in
      WalletOptionBottomSheet(
        title: sheet.title,
        assetTitle: .empty
      ) { type in
        viewModel.walletTypeButtonTapped(type: type)
      }
    }
    .refreshable {
      viewModel.onRefresh()
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
