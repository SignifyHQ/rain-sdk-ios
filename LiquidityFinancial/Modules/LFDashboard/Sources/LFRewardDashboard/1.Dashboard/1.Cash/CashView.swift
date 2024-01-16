import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFSolidBank
import LFTransaction
import LFSolidCard
  
struct CashView: View {
  @Environment(\.scenePhase) var scenePhase
  @StateObject private var viewModel: CashViewModel
  @State private var isNotLinkedCard = false
  
  let listCardViewModel: SolidListCardsViewModel
  
  init(listCardViewModel: SolidListCardsViewModel) {
    let cashViewModel = CashViewModel()
    _viewModel = .init(wrappedValue: cashViewModel)
    self.listCardViewModel = listCardViewModel
  }
  
  var body: some View {
    content
      .disabled(viewModel.isDisableView)
      .background(Colors.background.swiftUIColor)
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .transactions:
          TransactionListView(
            type: .cash,
            currencyType: viewModel.currencyType,
            accountID: viewModel.accountID,
            transactionTypes: Constants.TransactionTypesRequest.fiat.types
          )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            accountID: viewModel.accountID,
            transactionId: transaction.id,
            kind: transaction.detailType,
            isPopToRoot: false
          )
        case let .moveMoney(kind):
          MoveMoneyAccountView(kind: kind, cashBalance: viewModel.cashBalanceValue)
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
      .onChange(of: scenePhase) { newValue in
        viewModel.handleScenePhaseChange(scenePhase: newValue)
      }
      .track(name: String(describing: type(of: self)))
  }
}
  
// MARK: - Private View Components
private extension CashView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 16) {
        CashCardView(
          isNoLinkedCard: $isNotLinkedCard,
          isPOFlow: true, // !userManager.isGuest
          showLoadingIndicator: viewModel.isLoading,
          cashBalance: viewModel.cashBalanceValue,
          assetType: viewModel.selectedAsset,
          listCardViewModel: listCardViewModel
        )
        .overlay(alignment: .bottom) {
          depositButton
        }
        BalanceAlertView(
          type: .cash,
          hasContacts: !viewModel.linkedContacts.isEmpty,
          cashBalance: viewModel.cashBalanceValue
        ) {
          viewModel.addMoneyTapped()
        }
        moveMoney
        activity
      }
      .padding(.horizontal, 30)
      .padding(.top, 20)
      .padding(.bottom, 12)
    }
    .refreshable {
      viewModel.refreshable()
    }
  }
  
  var moveMoney: some View {
    HStack(spacing: 6) {
      iconTextButton(
        title: LFLocalizable.CashTab.Deposit.title,
        image: GenImages.CommonImages.addMoney.swiftUIImage
      ) {
        viewModel.addMoneyTapped()
      }
      iconTextButton(
        title: LFLocalizable.CashTab.Withdraw.title,
        image: GenImages.CommonImages.sendMoney.swiftUIImage
      ) {
        viewModel.sendMoneyTapped()
      }
    }
  }
  
  @ViewBuilder
  var depositButton: some View {
    if viewModel.transactions.isEmpty && viewModel.activity != .loading && !isNotLinkedCard {
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
  
  func iconTextButton(title: String, image: Image, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 8) {
        image
        Text(title)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.vertical, 12)
    }
    .frame(maxWidth: .infinity)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}
