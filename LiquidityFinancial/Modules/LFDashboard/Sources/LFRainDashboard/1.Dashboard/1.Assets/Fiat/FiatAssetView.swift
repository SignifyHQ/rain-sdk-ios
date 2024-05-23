import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import GeneralFeature
import RainFeature

struct FiatAssetView: View {
  @StateObject private var viewModel: FiatAssetViewModel
  
  init(asset: AssetModel) {
    _viewModel = .init(
      wrappedValue: .init(asset: asset)
    )
  }
  
  var body: some View {
    content
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .addMoney:
          MoveMoneyAccountView(kind: .receive) {
            viewModel.navigation = nil
          }
        case .sendMoney:
          MoveMoneyAccountView(kind: .send) {
            viewModel.navigation = nil
          }
        case .transactions:
          TransactionListView(
            filterType: .account,
            currencyType: viewModel.currencyType,
            contractAddress: viewModel.asset.id,
            transactionTypes: Constants.TransactionTypesRequest.fiat.types
          )
        case let .transactionDetail(transaction):
            TransactionDetailView(
              method: .transactionID(transaction.id),
              kind: transaction.detailType,
              isPopToRoot: false
            )
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
      .defaultToolBar(navigationTitle: viewModel.title)
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.refreshData()
      }
  }
}

// MARK: - View Components
private extension FiatAssetView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 10) {
        balance
        moveMoney
        // accountDetailView
        activity
      }
      .padding(.top, 26)
      .padding(.bottom, 16)
      .padding(.horizontal, 30)
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
        title: L10N.Common.CashTab.Deposit.title,
        image: GenImages.CommonImages.addMoney.swiftUIImage
      ) {
        viewModel.addMoneyTapped()
      }
      iconTextButton(
        title: L10N.Common.CashTab.Withdraw.title,
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
        title: L10N.Common.AccountView.RoutingNumber.title,
        value: viewModel.achInformation.routingNumber
      )
      accountDetailCell(
        image: GenImages.CommonImages.icAccountNumber.swiftUIImage,
        title: L10N.Common.AccountView.AccountNumber.title,
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
          title: L10N.Common.CashTab.LastestTransaction.title,
          onTapTransactionCell: viewModel.transactionItemTapped,
          seeAllAction: {
            viewModel.onClickedSeeAllButton()
          }
        )
      case .addFund:
        addFundsView
      case .failure:
        EmptyView()
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
        viewModel: AddFundsViewModel(),
        achInformation: $viewModel.achInformation,
        isDisableView: $viewModel.isDisableView
      )
    }
  }
}
