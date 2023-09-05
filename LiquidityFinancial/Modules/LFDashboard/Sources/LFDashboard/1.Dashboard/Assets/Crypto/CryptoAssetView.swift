import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFTransaction
import LFCryptoChart
import BaseDashboard

struct CryptoAssetView: View {
  @StateObject private var viewModel: CryptoAssetViewModel

  init(asset: AssetModel) {
    _viewModel = .init(
      wrappedValue: .init(asset: asset)
    )
  }

  var body: some View {
    content
      .blur(radius: viewModel.showTransferSheet ? 16 : 0)
      .sheet(isPresented: $viewModel.showTransferSheet) {
        cryptoTransfer
          .customPresentationDetents(height: 228)
          .ignoresSafeArea(edges: .bottom)
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .buyCrypto:
          MoveCryptoInputView(type: .buyCrypto, assetModel: viewModel.asset)
        case .sellCrypto:
          MoveCryptoInputView(type: .sellCrypto, assetModel: viewModel.asset)
        case .receiveCrypto:
          ReceiveCryptoView(assetModel: viewModel.asset)
        case .sendCrypto:
          EnterCryptoAddressView(assetModel: viewModel.asset)
        case .transactions:
            TransactionListView(
              type: .crypto,
              currencyType: viewModel.currencyType,
              accountID: viewModel.asset.id,
              transactionTypes: Constants.TransactionTypesRequest.crypto.types
            )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            accountID: viewModel.asset.id,
            transactionId: transaction.id,
            kind: transaction.detailType,
            isPopToRoot: false
          )
        case .chartDetail:
          CryptoChartDetailView(
            filterOptionSubject: viewModel.filterOptionSubject,
            chartOptionSubject: viewModel.chartOptionSubject,
            asset: viewModel.asset
          )
        }
      }
      .defaultToolBar(navigationTitle: viewModel.asset.type?.title ?? .empty)
      .sheet(item: $viewModel.sheet) { item in
        switch item {
        case .wallet:
          ReceiveCryptoView(assetModel: viewModel.asset)
            .embedInNavigation()
        }
      }
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.refreshData()
      }
  }
}

// MARK: - View Components
private extension CryptoAssetView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 10) {
        balance
        priceView
        CryptoChartView(
          filterOptionSubject: viewModel.filterOptionSubject,
          chartOptionSubject: viewModel.chartOptionSubject
        )
        .setHighlightValueEnable(false)
        .setGridXEnable(false)
        .setGridYEnable(true)
        .frame(height: 184)
        .padding(.horizontal, -30)
        .onTapGesture {
          viewModel.cryptoChartTapped()
        }
        BalanceAlertView(type: .crypto, hasContacts: true, cryptoBalance: viewModel.asset.availableBalance) {
          viewModel.walletRowTapped()
        }
        HStack(spacing: 10) {
          iconTextButton(
            title: LFLocalizable.AssetView.Buy.title,
            image: GenImages.CommonImages.buy.swiftUIImage
          ) {
            viewModel.onClickedBuyButton()
          }
          iconTextButton(
            title: LFLocalizable.AssetView.Sell.title,
            image: GenImages.CommonImages.sell.swiftUIImage
          ) {
            viewModel.onClickedSellButton()
          }
          iconTextButton(
            title: LFLocalizable.AssetView.Transfer.title,
            image: GenImages.CommonImages.transfer.swiftUIImage
          ) {
            viewModel.transferButtonTapped()
          }
        }
        .padding(.top, 6)
        ArrowButton(
          image: GenImages.CommonImages.walletAddress.swiftUIImage,
          title: LFLocalizable.AssetView.walletAddress,
          value: Constants.Default.walletAddressPlaceholder.rawValue
        ) {
          viewModel.receiveButtonTapped()
        }
        activity
        Spacer()
        disclosure
          .padding(.bottom, 8)
      }
      .padding(.top, 20)
      .padding(.horizontal, 30)
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
        ShortTransactionsView(
          transactions: $viewModel.transactions,
          title: LFLocalizable.CashTab.LastestTransaction.title,
          onTapTransactionCell: viewModel.transactionItemTapped,
          seeAllAction: {
            viewModel.onClickedSeeAllButton()
          }
        )
      case .failure:
        EmptyView()
      }
    }
  }

  var balance: some View {
    VStack(alignment: .center, spacing: 4) {
      HStack(alignment: .center, spacing: 4) {
        Text(viewModel.cryptoBalance)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: 32))
        GenImages.Images.icCrypto.swiftUIImage
          .foregroundColor(Colors.primary.swiftUIColor)
      }
      Text(viewModel.usdBalance)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
          Rectangle()
            .cornerRadius(32)
            .foregroundColor(Colors.secondaryBackground.swiftUIColor)
        )
    }
  }
  
  var priceView: some View {
    HStack(spacing: 8) {
      Text(viewModel.cryptoPrice)
        .foregroundColor(Colors.primary.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
      HStack(spacing: 4) {
        if viewModel.isPositivePrice {
          Image(systemName: "arrow.up")
            .resizable()
            .scaledToFit()
            .frame(width: 7, height: 8)
            .foregroundColor(Colors.green.swiftUIColor)
        } else {
          Image(systemName: "arrow.down")
            .resizable()
            .scaledToFit()
            .frame(width: 7, height: 8)
            .foregroundColor(Colors.error.swiftUIColor)
        }
        Text(viewModel.changePercentAbsString)
          .foregroundColor(viewModel.isPositivePrice ? Colors.green.swiftUIColor : Colors.error.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
      }
      Text(LFLocalizable.AssetView.today)
        .foregroundColor(Colors.whiteText.swiftUIColor)
        .opacity(0.5)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
    }
  }
  
  var disclosure: some View {
    Text(LFLocalizable.AssetView.disclosure)
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .font(Fonts.bold.swiftUIFont(size: 10))
      .padding(.horizontal, 20)
      .multilineTextAlignment(.center)
  }
  
  func iconTextButton(title: String, image: Image, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      VStack(spacing: 6) {
        image
          .foregroundColor(Colors.label.swiftUIColor)
        Text(title)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.vertical, 12)
    }
    .frame(maxWidth: .infinity)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  var cryptoTransfer: some View {
    VStack(spacing: 10) {
      RoundedRectangle(cornerRadius: 4)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .frame(width: 32, height: 4)
        .padding(.top, 6)
      Text(LFLocalizable.AssetView.TransferPopup.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.vertical, 14)
      transferCell(
        with: GenImages.CommonImages.sell.swiftUIImage,
        and: LFLocalizable.AssetView.Send.title
      ) {
        viewModel.sendButtonTapped()
      }
      transferCell(
        with: GenImages.CommonImages.buy.swiftUIImage,
        and: LFLocalizable.AssetView.Receive.title
      ) {
        viewModel.receiveButtonTapped()
      }
      Spacer()
    }
    .padding(.horizontal, 30)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
  
  func transferCell(with image: Image, and title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        image
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.regular.value))
        Spacer()
        GenImages.Images.forwardButton.swiftUIImage
      }
      .foregroundColor(Colors.label.swiftUIColor)
      .frame(height: 56)
      .padding(.horizontal, 16)
      .background(Colors.buttons.swiftUIColor)
      .cornerRadius(9)
    }
  }
}
