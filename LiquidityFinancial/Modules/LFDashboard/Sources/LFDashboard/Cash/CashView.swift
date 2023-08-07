import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct CashView: View {
  @StateObject private var viewModel: CashViewModel
  
  init(guestHandler: @escaping () -> Void) {
    _viewModel = .init(
      wrappedValue: CashViewModel(guestHandler: guestHandler)
    )
  }
  
  var body: some View {
    Group {
      if viewModel.isCardActive {
        activeView
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
          assets: [.usd, .avax, .usdc]
        )
      case .transactions:
        EmptyView()
          // TransactionListView(type: .cash)
      case .addMoney:
        MoveMoneyAccountView(kind: .receive)
      }
    }
  }
}

private extension CashView {
  private var moveMoney: some View {
    HStack(spacing: 6) {
      iconTextButton(
        title: LFLocalizable.CashTab.Deposit.title,
        image: GenImages.CommonImages.addMoney
      ) {
        viewModel.addMoneyTapped()
      }
      iconTextButton(
        title: LFLocalizable.CashTab.Withdraw.title,
        image: GenImages.CommonImages.sendMoney
      ) {
        viewModel.sendMoneyTapped()
      }
    }
  }
  
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
        Text(LFLocalizable.CashTab.ChangeAsset.buttonTitle)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .frame(width: 100, height: 40)
          .background(Colors.buttons.swiftUIColor.cornerRadius(8))
      }
    }
    .padding(.leading, 16)
    .padding(.trailing, 8)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
  }
  
  var activeView: some View {
    GeometryReader { geo in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 16) {
          CashCardView(
            isPOFlow: true, // !userManager.isGuest
            showLoadingIndicator: viewModel.isLoading,
            cashBalance: viewModel.cashBalanceValue,
            assetType: viewModel.selectedAsset,
            cardDetails: $viewModel.cashCardDetails
          ) {
            viewModel.guestCardTapped()
          }
          changeAssetButton
          moveMoney
          activity(size: geo.size)
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .padding(.bottom, 12)
      }
      .onAppear {
        viewModel.appearOperations()
      }
      .refreshable {
        await viewModel.refresh()
      }
        // .track(name: String(describing: type(of: self))) TODO: Will be implemented later
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
      }
    }
  }
  
  var seeAllTransactions: some View {
    Button {
      viewModel.onClickedSeeAllButton()
    } label: {
      HStack(spacing: 8) {
        Text(LFLocalizable.CashTab.SeeAll.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .foregroundColor(Colors.label.swiftUIColor)
    }
  }
  
  func iconTextButton(title: String, image: ImageAsset, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 8) {
        image.swiftUIImage
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
  
  func transactionsView(size: CGSize) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .bottom) {
        Text(LFLocalizable.CashTab.LastestTransaction.title)
        Spacer()
        seeAllTransactions
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      if viewModel.transactions.isEmpty {
        noTransactionsYetView(height: size.height)
      } else {
        EmptyView()
          // TODO: Will be implemented later
          //      ForEach(items) { transaction in
          //        TransactionRowView(item: transaction, type: .cash) {
          //          viewModel.transactionItemTapped(transaction)
          //        }
          //      }
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
}
