import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import GeneralFeature
import SolidFeature

struct CashAssetView: View {
  @StateObject private var viewModel: CashAssetViewModel
  
  init() {
    _viewModel = .init(
      wrappedValue: .init()
    )
  }
  
  var body: some View {
    content
      .disabled(viewModel.isDisableView)
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
            accountID: viewModel.assetModel?.id,
            transactionTypes: Constants.TransactionTypesRequest.fiat.types
          )
        case let .transactionDetail(transaction):
            TransactionDetailView(
              accountID: viewModel.assetModel?.id,
              transactionId: transaction.id,
              kind: transaction.detailType,
              isPopToRoot: false
            )
        case .accountRounting:
          AccountRountingNumberView(achInformation: $viewModel.achInformation)
        case .fundingAccount:
          FundingAccountsView(linkedContacts: viewModel.linkedContacts, achInformation: $viewModel.achInformation)
        case .depositWithdrawalLimits:
          AccountLimitsView()
        case .allCards:
          CardsTabView(title: L10N.Common.CashAsset.ConnectedCards.title.uppercased())
        case .cardDetail(let viewModel):
          CardDetailView(viewModel: viewModel)
        case .cardListDetail(let viewModel):
          SolidListCardsView(viewModel: viewModel)
        case .bankStatements:
          BankStatementView()
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
private extension CashAssetView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 10) {
        balance
        moveMoney
        actionView
        if viewModel.linkedContacts.isEmpty {
          fundsView
        }
        if viewModel.filteredCardsList.isNotEmpty {
          connectedCards
        }
        if viewModel.activity != .empty {
          activity
          bankStatements
        }
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
      if let assetType = viewModel.assetModel?.type {
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
  
  var actionView: some View {
    VStack(alignment: .leading, spacing: 10) {
      if viewModel.linkedContacts.isNotEmpty {
        ArrowButton(
          image: GenImages.CommonImages.Assets.funding.swiftUIImage,
          title: L10N.Common.CashAsset.FundingAccounts.title,
          value: nil
        ) {
          viewModel.fundingAccountTapped()
        }
      }
      ArrowButton(
        image: GenImages.CommonImages.Assets.rounting.swiftUIImage,
        title: L10N.Common.CashAsset.AccountRountingNumber.title,
        value: nil
      ) {
        viewModel.accountRountingTapped()
      }
      if viewModel.linkedContacts.isNotEmpty || viewModel.transactions.isNotEmpty {
        ArrowButton(
          image: GenImages.CommonImages.Assets.depositWithdrawalLimits.swiftUIImage,
          title: L10N.Common.CashAsset.DepositWithdrawalLimits.title,
          value: nil
        ) {
          viewModel.depositWithdrawalLimitsTapped()
        }
      }
    }
  }
  
  var bankStatements: some View {
    ArrowButton(
      image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
      title: L10N.Common.CashAsset.BankStatements.title,
      value: nil
    ) {
      viewModel.bankStatementsTapped()
    }
  }
  
  var fundsView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.CashAsset.FundingAccounts.title)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      AddFundsView(
        viewModel: viewModel.addFundsViewModel,
        achInformation: $viewModel.achInformation,
        isDisableView: $viewModel.isDisableView,
        options: [.directDeposit, .oneTime]
      )
    }
  }
  
  var createCard: some View {
    Button {
      // TODO: Will navigate to create card
    } label: {
      VStack(spacing: 8) {
        ZStack {
          GenImages.CommonImages.Assets.createCard.swiftUIImage
        }
        .frame(width: 80, height: 80)
        .background(Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(16)
        
        Text(L10N.Common.CashAsset.CreateCard.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
  }
  
  var connectedCardHeader: some View {
    HStack(alignment: .bottom) {
      Text(L10N.Common.CashAsset.ConnectedCards.title)
      Spacer()
      if viewModel.showAllConnectedCard {
        Button {
          viewModel.seeAllConnectedCards()
        } label: {
          HStack(spacing: 8) {
            Text(L10N.Common.AssetView.seeAll)
            GenImages.CommonImages.icRightArrow.swiftUIImage
          }
          .frame(height: 30, alignment: .bottom)
        }
      }
    }
    .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
  }
  
  func cardView(card: CardModel, action: @escaping () -> Void) -> some View {
    VStack(spacing: 8) {
      Button {
        action()
      } label: {
        ZStack {
          GenImages.CommonImages.Assets.assetCard.swiftUIImage
        }
        .frame(width: 80, height: 80)
        .background(Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(16)
      }
      
      Text(card.cardName)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
    }
  }
  
  var connectedCards: some View {
    VStack(alignment: .leading, spacing: 12) {
      connectedCardHeader
      
      ScrollView(.horizontal) {
        HStack(spacing: 24) {
          // TODO: Temporarily hidden for release, will reopen when Phase 2 is ready
          // createCard
          
          ForEach(viewModel.filteredCardsList) { card in
            cardView(card: card) {
              viewModel.navigateToCardDetail(card: card)
            }
          }
        }
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
      case .failure, .empty:
        EmptyView()
      }
    }
  }
}
