import Combine
import GeneralFeature
import SwiftUI
import CryptoChartData
import AccountDomain
import LFStyleGuide
import LFUtilities
import LFLocalizable
import RainFeature

struct CryptoChartDetailView: View {
  @StateObject private var viewModel: CryptoChartDetailViewModel
  
  var filterOptionSubject: CurrentValueSubject<CryptoFilterOption, Never>
  var chartOptionSubject: CurrentValueSubject<ChartOption, Never>
  
  init(
    filterOptionSubject: CurrentValueSubject<CryptoFilterOption, Never>,
    chartOptionSubject: CurrentValueSubject<ChartOption, Never>,
    asset: AssetModel
  ) {
    self.filterOptionSubject = filterOptionSubject
    self.chartOptionSubject = chartOptionSubject
    _viewModel = .init(wrappedValue: CryptoChartDetailViewModel(asset: asset))
  }
  
  var body: some View {
    content
      .blur(radius: viewModel.showTransferSheet ? 16 : 0)
      .sheet(isPresented: $viewModel.showTransferSheet) {
        cryptoTransfer
          .customPresentationDetents(height: 228)
          .ignoresSafeArea(edges: .bottom)
      }
      .onAppear {
        viewModel.appearOperations()
      }
      .refreshable {
        await viewModel.refresh()
      }
      .background(Colors.background.swiftUIColor)
      .defaultToolBar(navigationTitle: LFUtilities.cryptoCurrency.uppercased())
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .addMoney:
          MoveMoneyAccountView(kind: .receive)
        case .send:
          EnterWalletAddressView(
            viewModel: EnterWalletAddressViewModel(asset: viewModel.asset, kind: .sendCrypto)
          ) {
            viewModel.navigation = nil
          }
        case .receive:
          ReceiveCryptoView(assetModel: viewModel.asset)
        case .buy:
          MoveCryptoInputView(type: .buyCrypto, assetModel: viewModel.asset)
        case .sell:
          MoveCryptoInputView(type: .sellCrypto, assetModel: viewModel.asset)
        }
      }
      .sheet(item: $viewModel.sheet) { item in
        buildFor(item: item)
      }
      .popup(item: $viewModel.popup) { popup in
        switch popup {
        case .sendBalance:
          transferBalancePopup
        }
      }
  }
}

private extension CryptoChartDetailView {
  var selectInfoDetailView: some View {
    VStack(alignment: .leading, spacing: 8) {
      selectInfoCell(title: L10N.Common.CryptoChartDetail.Open.title, value: viewModel.openPrice)
      selectInfoCell(title: L10N.Common.CryptoChartDetail.Close.title, value: viewModel.closePrice)
      selectInfoCell(title: L10N.Common.CryptoChartDetail.High.title, value: viewModel.highPrice)
      selectInfoCell(title: L10N.Common.CryptoChartDetail.Low.title, value: viewModel.lowPrice)
      selectInfoCell(title: L10N.Common.CryptoChartDetail.Volume.title, value: viewModel.volumePrice)
    }
  }
  
  func selectInfoCell(title: String, value: String) -> some View {
    HStack {
      Text(title)
        .foregroundColor(Colors.whiteText.swiftUIColor.opacity(0.5))
        .font(Fonts.regular.swiftUIFont(size: 10))
      Spacer()
      Text(value)
        .foregroundColor(Colors.whiteText.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: 10))
    }
    .frame(height: 12)
  }
  
  var priceDetailView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(viewModel.cryptoPrice)
        .foregroundColor(balanceTitleColor)
        .font(Fonts.bold.swiftUIFont(size: 30))
      HStack(spacing: 8) {
        Text(L10N.Common.CryptoChartDetail.Change.title)
          .foregroundColor(Colors.whiteText.swiftUIColor.opacity(0.5))
          .font(Fonts.regular.swiftUIFont(size: 10))
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
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        }
      }
    }
  }
  
  var topView: some View {
    HStack {
      Spacer()
        .frame(width: 24)
      priceDetailView
      Spacer()
      selectInfoDetailView
        .frame(width: 124)
      Spacer()
        .frame(width: 24)
    }
    .frame(height: 92)
  }
  
  var content: some View {
    VStack(spacing: 6) {
      topView
      VStack(spacing: 10) {
        CryptoChartView(
          filterOptionSubject: filterOptionSubject,
          chartOptionSubject: chartOptionSubject
        )
        .setSelectedHistoricalPriceSubject(
          viewModel.selectedHistoricalPriceSubject
        )
        .setGridXEnable(true)
        .setGridYEnable(true)
        
        transferButton
      }
      .padding(.bottom, 12)
      .padding(.top, 20)
    }
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
    .padding(.horizontal, 30)
  }
  
  var activity: some View {
    Group {
      switch viewModel.activity {
      case .loading:
        LottieView(loading: .mix)
          .frame(width: 30, height: 20)
      case .failure:
        EmptyView()
      }
    }
  }
  
  var priceView: some View {
    HStack(spacing: 8) {
      Text(viewModel.cryptoPrice.formattedUSDAmount())
        .foregroundColor(Colors.primary.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
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
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
      Text(L10N.Common.CryptoChartDetail.Today.title)
        .foregroundColor(Colors.whiteText.swiftUIColor.opacity(0.5))
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
  }
  
  var disclosure: some View {
    Text(L10N.Common.Zerohash.Disclosure.description)
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .font(Fonts.regular.swiftUIFont(size: 10))
      .padding(.horizontal, 20)
      .multilineTextAlignment(.center)
  }
  
  var transferBalancePopup: some View {
    LiquidityAlert(
      title: L10N.Common.CryptoChartDetail.TransferBalance.title(LFUtilities.cryptoCurrency.uppercased()),
      message: .empty,
      primary: .init(text: L10N.Common.Button.Ok.title.uppercased()) {
        viewModel.clearPopup()
      }
    )
  }
  
  @ViewBuilder func buildFor(item: CryptoChartDetailViewModel.SheetPresentation) -> some View {
    switch item {
    case let .trxDetail(model):
      TransactionDetailView(
        accountID: viewModel.asset.id,
        transactionId: model.id,
        kind: model.detailType
      )
      .embedInNavigation()
    case .wallet:
      ReceiveCryptoView(assetModel: viewModel.asset)
        .embedInNavigation()
    }
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
      Text(L10N.Common.CryptoChartDetail.TransferCoin.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.vertical, 14)
      transferCell(with: GenImages.CommonImages.sell.swiftUIImage, and: L10N.Common.CryptoChartDetail.Send.title) {
        viewModel.sendButtonTapped()
      }
      transferCell(with: GenImages.CommonImages.buy.swiftUIImage, and: L10N.Common.CryptoChartDetail.Receive.title) {
        viewModel.receiveButtonTapped()
      }
      Spacer()
    }
    .padding(.horizontal, 30)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
  
  func transferCell(
    with image: Image,
    and title: String,
    action: @escaping () -> Void
  ) -> some View {
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

// MARK: - ViewHelpers
private extension CryptoChartDetailView {
  var balanceTitleColor: Color {
    switch LFStyleGuide.target {
    case .DogeCard:
      return Colors.primary.swiftUIColor
    default:
      return Colors.label.swiftUIColor
    }
  }
}
