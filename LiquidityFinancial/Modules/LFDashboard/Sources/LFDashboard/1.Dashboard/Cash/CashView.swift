import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFBank
import LFTransaction
import LFCard
import LFAccountOnboarding

struct CashView: View {
  @StateObject private var viewModel: CashViewModel
  let listCardViewModel: ListCardsViewModel
  var onRefresh: (() -> Void)
  
  init(viewModel: CashViewModel, listCardViewModel: ListCardsViewModel, onRefresh: @escaping (() -> Void)) {
    _viewModel = .init(
      wrappedValue: viewModel
    )
    self.listCardViewModel = listCardViewModel
    self.onRefresh = onRefresh
  }
  
  var body: some View {
    Group {
      if viewModel.isCardActive {
        activeView
          .disabled(viewModel.isDisableView)
      } else {
        ErrorView(message: LFLocalizable.CashTab.DeActiveError.message)
      }
    }
    .background(Colors.background.swiftUIColor)
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .bankStatements:
        EmptyView()
          // BankStatementsListView()
      case .changeAsset:
        ChangeAssetView(
          selectedAsset: $viewModel.selectedAsset,
          balance: viewModel.cashBalanceValue,
          assets: viewModel.assets
        )
      case .transactions:
        TransactionListView(
          type: .cash,
          currencyType: viewModel.currencyType,
          accountID: viewModel.accountDataManager.fiatAccountID,
          transactionTypes: Constants.TransactionTypesRequest.fiat.types
        )
      case .addMoney:
        MoveMoneyAccountView(kind: .receive)
      case .sendMoney:
        MoveMoneyAccountView(kind: .send)
      case let .transactionDetail(transaction):
        TransactionDetailView(
          accountID: viewModel.accountDataManager.fiatAccountID,
          transactionId: transaction.id,
          kind: transaction.detailType,
          isPopToRoot: false
        )
      case .agreement(let data):
        AgreementView(
          viewModel: AgreementViewModel(fundingAgreement: data),
          onNext: {
            //self.viewModel.addFundsViewModel.fundingAgreementData.send(nil)
          }, onDisappear: { isAcceptAgreement in
            self.viewModel.handleFundingAcceptAgreement(isAccept: isAcceptAgreement)
          }, shouldFetchCurrentState: false)
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
          isPOFlow: true, // !userManager.isGuest
          showLoadingIndicator: viewModel.isLoading,
          cashBalance: viewModel.cashBalanceValue,
          assetType: viewModel.selectedAsset,
          cardDetails: $viewModel.cashCardDetails,
          listCardViewModel: listCardViewModel
        ) {
          viewModel.guestCardTapped()
        }
        .overlay(alignment: .bottom) {
          depositButton
        }
        /* TODO: Remove for MVP
        changeAssetButton
         */
        BalanceAlertView(type: .cash, hasContacts: !viewModel.linkedAccount.isEmpty, cashBalance: viewModel.cashBalanceValue) {
          viewModel.addMoneyTapped()
        }
        activity
      }
      .padding(.horizontal, 30)
      .padding(.top, 20)
      .padding(.bottom, 12)
    }
    .refreshable {
      onRefresh()
    }
  }
  
  @ViewBuilder var depositButton: some View {
    if viewModel.transactions.isEmpty && viewModel.activity != .loading {
      Button {
        viewModel.addMoneyTapped()
      } label: {
        Text(LFLocalizable.CashTab.Deposit.title)
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
      case .addFunds:
          addFundsView
      case .transactions:
        ShortTransactionsView(
          transactions: $viewModel.transactions,
          title: LFLocalizable.CashTab.LastestTransaction.title,
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
      Text(LFLocalizable.CashTab.WaysToAdd.title)
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
}
