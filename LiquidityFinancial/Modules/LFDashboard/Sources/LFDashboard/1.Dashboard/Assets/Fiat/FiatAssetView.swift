import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFBank
import LFTransaction

struct FiatAssetView: View {
  @StateObject private var viewModel: FiatAssetViewModel
  
  init(asset: AssetModel, guestHandler: @escaping () -> Void) {
    _viewModel = .init(
      wrappedValue: .init(asset: asset, guestHandler: guestHandler)
    )
  }
  
  var body: some View {
    content
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .addMoney:
          MoveMoneyAccountView(kind: .receive)
        case .sendMoney:
          MoveMoneyAccountView(kind: .send)
        case .transactions:
          TransactionListView(
            type: .crypto,
            currencyType: viewModel.currencyType,
            accountID: viewModel.account?.id ?? .empty
          )
        case let .transactionDetail(transaction):
          TransactionDetailView(transactionId: transaction.id, kind: transaction.detailType)
        }
      }
      .defaultToolBar(navigationTitle: viewModel.asset.type?.title ?? .empty)
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.refreshData()
      }
  }
}

// MARK: - View Components
private extension FiatAssetView {
  var content: some View {
    GeometryReader { geo in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 10) {
          balance
          moveMoney
          accountDetailView
          activity(size: geo.size)
        }
        .padding(.top, 26)
        .padding(.bottom, 16)
        .padding(.horizontal, 30)
      }
    }
  }
  
  var balance: some View {
    HStack(alignment: .center, spacing: 10) {
      Text(viewModel.usdBalance)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: 30))
      if let assetType = viewModel.asset.type {
        assetType.image
      } else {
        GenImages.CommonImages.icUsd.swiftUIImage
      }
    }
    .padding(.bottom, 22)
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
  
  var accountDetailView: some View {
    VStack(spacing: 10) {
      accountDetailCell(
        image: GenImages.CommonImages.icRoutingNumber.swiftUIImage,
        title: LFLocalizable.AccountView.RoutingNumber.title,
        value: viewModel.achInformation.routingNumber
      )
      accountDetailCell(
        image: GenImages.CommonImages.icAccountNumber.swiftUIImage,
        title: LFLocalizable.AccountView.AccountNumber.title,
        value: viewModel.achInformation.accountNumber
      )
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
  
  func accountDetailCell(image: Image, title: String, value: String) -> some View {
    HStack(spacing: 12) {
      image
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: 13))
      Spacer()
      if viewModel.isLoadingACH {
        LottieView(loading: .primary)
          .frame(width: 28, height: 16)
          .padding(.leading, 4)
      } else {
        Text(value)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.primary.swiftUIColor)
      }
    }
    .padding(.leading, 16)
    .padding(.trailing, 12)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
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
        Text(LFLocalizable.CashTab.LastestTransaction.title)
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
        Text(LFLocalizable.AssetView.seeAll)
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .frame(height: 30, alignment: .bottom)
    }
  }
}
