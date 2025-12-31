import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import RainFeature
import Services
import GeneralFeature

struct DashboardView: View {
  @Environment(\.scenePhase) var scenePhase
  
  @StateObject private var viewModel: DashboardViewModel
  @StateObject var transactionFilterViewModel = TransactionFilterViewModel()
  let cardDetailsListViewModel: CardDetailsListViewModel
  
  @State private var isNotLinkedCard = false
  
  init(
    viewModel: DashboardViewModel,
    cardDetailsListViewModel: CardDetailsListViewModel
  ) {
    _viewModel = .init(
      wrappedValue: viewModel
    )
    
    self.cardDetailsListViewModel = cardDetailsListViewModel
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 36) {
        cardView
        stateView
        Spacer()
      }
      .padding(.bottom, 16)
    }
    .padding(.horizontal, 24)
    .padding(.top, 4)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .toast(data: $viewModel.toastData)
    .track(name: String(describing: type(of: self)))
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .transactions:
        TransactionsView(
          currencyType: viewModel.currencyType,
          transactionTypes: Constants.TransactionTypesRequest.fiat.types
        )
      case let .transactionDetail(transaction):
        TransactionDetailsView(
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
      case .addToCard:
        AddToCardView()
      case let .enterWithdrawalAmount(address, assetCollateral):
        MoveCryptoInputView(
          type: .withdrawCollateral(address: address, nickname: nil, shouldSaveAddress: false),
          assetModel: assetCollateral,
          completeAction: {
            viewModel.navigation = nil
          }
        )
      case let .enterWalletAddress(assetCollateral):
        WalletAddressEntryView(
          viewModel: WalletAddressEntryViewModel(asset: assetCollateral, kind: .withdrawCollateral)
        ) {
          viewModel.navigation = nil
        }
      }
    }
    .onChange(
      of: scenePhase,
      perform: { newValue in
        if newValue == .background {
          viewModel.shouldReloadListTransaction = true
        }
        if newValue == .active && viewModel.shouldReloadListTransaction {
          viewModel.shouldReloadListTransaction = false
          
          Task {
            await viewModel.onRefreshAllData(isAnimated: true)
          }
        }
      }
    )
    .onChange(
      of: transactionFilterViewModel.didApplyChanges
    ) { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        viewModel.filterConfiguration = transactionFilterViewModel.filterConfiguration
        
        Task {
          try await viewModel.refreshTransaction(withAnimation: true)
        }
      }
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
      await viewModel.onRefreshAllData(isAnimated: false)
    }
    .sheet(
      item: $viewModel.presentedFilterSheet
    ) { _ in
      TransactionFilterSheetView(
        viewModel: transactionFilterViewModel,
        presentedFilterSheet: $viewModel.presentedFilterSheet
      )
      .presentationDetents([.height(310), .height(350)])
      .presentationDragIndicator(.hidden)
      .onAppear(
        perform: {
          transactionFilterViewModel.filterConfiguration = viewModel.filterConfiguration
        }
      )
    }
  }
}

extension DashboardView {
  var cardView: some View {
    VStack(spacing: 24) {
      DashboardCardView(
        isNoLinkedCard: $isNotLinkedCard,
        isPOFlow: true,
        showLoadingIndicator: viewModel.isLoading,
        cashBalance: viewModel.cashBalanceValue,
        assetType: viewModel.selectedAsset,
        cardDetailsListViewModel: cardDetailsListViewModel
      ) {
      }
      
      HStack(spacing: 16) {
        addFundsButton
        withdrawFundsButton
      }
    }
  }
  
  var stateView: some View {
    Group {
      switch viewModel.activity {
      case .loading:
        DefaultLottieView(loading: .ctaRegular)
          .frame(width: 32, height: 32)
          .padding(.top, 8)
      default:
        if viewModel.transactions.isEmpty {
          noStateView
        } else {
          transactionsView
        }
      }
    }
  }
  
  var addFundsButton: some View {
    FullWidthButton(
      type: .primary,
      height: 40,
      icon: GenImages.Images.icoPlus.swiftUIImage,
      iconPlacement: .trailing(spacing: 4),
      title: L10N.Common.Dashboard.Card.AddFunds.title,
      font: Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value)
    ) {
      viewModel.onAddFundsButtonTap()
    }
  }
  
  var withdrawFundsButton: some View {
    FullWidthButton(
      type: .primary,
      height: 40,
      icon: GenImages.Images.icoArrowDown.swiftUIImage,
      iconPlacement: .trailing(spacing: 4),
      title: L10N.Common.Dashboard.Card.WithdrawFunds.title,
      font: Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value)
    ) {
      viewModel.onWithdrawFundsButtonTap()
    }
  }
  
  var transactionsView: some View {
    VStack(spacing: 12) {
      HStack {
        Text(L10N.Common.Dashboard.Transactions.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        
        Spacer()
        
        Button {
          viewModel.onSeeAllTransactionsButton()
        } label: {
          seeAllView
        }
      }
      
      VStack(spacing: 0) {
        ForEach(viewModel.transactions.prefix(10), id: \.id) { item in
          transactionItem(transaction: item)
        }
      }
    }
  }
  
  func transactionItem(transaction: TransactionModel) -> some View {
    TransactionItemView(transaction: transaction) {
      viewModel.onTransactionItemTap(transaction)
    }
  }
  
  var noStateView: some View {
    VStack(spacing: 36) {
      getStartedView
      //resourcesView
    }
  }
  
  var getStartedView: some View {
    VStack(spacing: 12) {
      GenImages.Images.icoGetStarted.swiftUIImage
        .resizable()
        .frame(width: 104, height: 62)
        .aspectRatio(contentMode: .fit)
      
      VStack(spacing: 4) {
        Text(L10N.Common.Dashboard.NoState.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.main.value))
          .multilineTextAlignment(.center)
        
        Text(L10N.Common.Dashboard.NoState.subtitle)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .multilineTextAlignment(.center)
      }
      
      FullWidthButton(
        type: .secondary,
        borderColor: Colors.greyDefault.swiftUIColor,
        title: L10N.Common.Dashboard.NoState.HowItWorks.Button.title
      ) {
        viewModel.openGetStartedURL()
      }
    }
    .padding(16)
    .cornerRadius(36)
    .overlay {
      RoundedRectangle(cornerRadius: 36)
        .stroke(Colors.greyDefault.swiftUIColor, lineWidth: 1)
    }
  }
  
  var resourcesView: some View {
    VStack(spacing: 20) {
      HStack {
        Text(L10N.Common.Dashboard.Resources.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        
        Spacer()
        
        Button {
          // TODO: Full resources view
        } label: {
          seeAllView
        }
      }
      
      VStack(spacing: 0) {
        ForEach(viewModel.tutorialResources, id: \.id) { item in
          resourceItem(item)
            .onTapGesture {
              if let url = item.url {
                viewModel.openURL(url)
              }
            }
        }
      }
    }
  }
  
  func resourceItem(_ item: DashboardViewModel.TutorialResource) -> some View {
    HStack(alignment: .center, spacing: 12) {
      item.icon
        .resizable()
        .frame(width: 64, height: 64)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(item.subtitle)
          .foregroundColor(Colors.textTertiary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        
        Text(item.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      }
      
      Spacer()
      
      Image(systemName: "plus")
        .resizable()
        .frame(width: 16, height: 16, alignment: .center)
        .foregroundStyle(Colors.iconHover.swiftUIColor)
    }
    .padding(12)
    .cornerRadius(24)
    .overlay {
      RoundedRectangle(cornerRadius: 24)
        .stroke(Colors.greyDefault.swiftUIColor, lineWidth: 1)
    }
  }
  
  var seeAllView: some View {
    HStack(spacing: 0) {
      Text(L10N.Common.Common.SeeAll.Button.title)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      
      Image(systemName: "chevron.right")
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundStyle(Colors.iconPrimary.swiftUIColor)
        .frame(width: 24, height: 24, alignment: .center)
    }
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}

// MARK: Helpers
extension DashboardView {
  func formattedAmount(transaction: TransactionModel) -> String {
    transaction.amount.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: transaction.isCryptoTransaction ? Constants.FractionDigitsLimit.crypto.minFractionDigits : Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: transaction.isCryptoTransaction ? Constants.FractionDigitsLimit.crypto.maxFractionDigits : Constants.FractionDigitsLimit.fiat.maxFractionDigits
    )
  }
}
