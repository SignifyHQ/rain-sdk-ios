import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import GeneralFeature

struct CryptoAssetView: View {
  @StateObject private var viewModel: CryptoAssetViewModel

  init(asset: AssetModel) {
    print(asset)
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
          ReceiveCryptoView(
            assetTitle: viewModel.asset.type?.title ?? .empty,
            walletAddress: viewModel.asset.externalAccountId ?? .empty
          )
        case .sendCrypto:
          EnterWalletAddressView(
            viewModel: EnterWalletAddressViewModel(asset: viewModel.asset, kind: .sendCrypto)
          ) {
            viewModel.navigation = nil
          }
        case .transactions:
            TransactionListView(
              currencyType: viewModel.currencyType,
              contractAddress: viewModel.asset.id,
              transactionTypes: Constants.TransactionTypesRequest.crypto.types
            )
        case let .transactionDetail(transaction):
          TransactionDetailView(
            method: .transactionID(transaction.id),
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
          ReceiveCryptoView(
            assetTitle: viewModel.asset.type?.title ?? .empty,
            walletAddress: viewModel.asset.externalAccountId ?? .empty
          )
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
        
        HStack {
          cryptoButtons
        }
        .frame(height: 76)
        
        walletAddressButton
        activity
        Spacer()
        disclosure
          .padding(.bottom, 8)
      }
      .padding(.top, 20)
      .padding(.horizontal, 30)
    }
  }
  
  var cryptoButtons: some View {
    // (Volo): Hiding Buy and Sell for now since it's not supported currently
    HStack(spacing: 10) {
      iconTextButton(
        title: L10N.Common.AssetView.Send.title,
        image: GenImages.CommonImages.sell.swiftUIImage
      ) {
        viewModel.sendButtonTapped()
      }
      iconTextButton(
        title: L10N.Common.AssetView.Receive.title,
        image: GenImages.CommonImages.buy.swiftUIImage
      ) {
        viewModel.receiveButtonTapped()
      }
//      iconTextButton(
//        title: L10N.Common.AssetView.Transfer.title,
//        image: GenImages.CommonImages.transfer.swiftUIImage
//      ) {
//        viewModel.transferButtonTapped()
//      }
    }
    .padding(.top, 6)
  }
  
  var transferButton: some View {
    Button {
      viewModel.transferButtonTapped()
    } label: {
      HStack(spacing: 8) {
        GenImages.CommonImages.transfer.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        Text(L10N.Common.AssetView.Transfer.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        GenImages.CommonImages.icRightArrow.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.horizontal, 12)
      .frame(height: 56)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
    }
  }
  
  var walletAddressButton: some View {
    Button {
      viewModel.receiveButtonTapped()
    } label: {
      HStack(spacing: 8) {
        GenImages.CommonImages.walletAddress.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        Text(L10N.Common.AssetView.walletAddress)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Text(Constants.Default.walletAddressPlaceholder.rawValue)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(walletPlaceHolderColor)
          .offset(y: 3)
      }
      .padding(.horizontal, 12)
      .frame(height: 56)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
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
          title: L10N.Common.CashTab.LastestTransaction.title,
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
        if let icon = viewModel.cryptoIconImage {
          icon.foregroundColor(Colors.primary.swiftUIColor)
        }
      }
      HStack(spacing: 4) {
        Text(viewModel.usdBalance)
          .foregroundColor(Colors.label.swiftUIColor)
        Text(viewModel.fluctuationAmmount)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      }
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
      Text(L10N.Common.AssetView.today)
        .foregroundColor(Colors.whiteText.swiftUIColor)
        .opacity(0.5)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
    }
  }
  
  var disclosure: some View {
    Text(L10N.Common.AssetView.disclosure)
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
      Text(L10N.Common.AssetView.TransferPopup.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.vertical, 14)
      transferCell(
        with: GenImages.CommonImages.sell.swiftUIImage,
        and: L10N.Common.AssetView.Send.title
      ) {
        viewModel.sendButtonTapped()
      }
      transferCell(
        with: GenImages.CommonImages.buy.swiftUIImage,
        and: L10N.Common.AssetView.Receive.title
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

// MARK: - View Helpers
private extension CryptoAssetView {
  var walletPlaceHolderColor: Color {
    switch LFStyleGuide.target {
    case .Cardano:
      return Colors.label.swiftUIColor
    default:
      return Colors.primary.swiftUIColor
    }
  }
}
