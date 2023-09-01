import Combine
import SwiftUI
import CryptoChartData
import AccountDomain
import LFCryptoChart
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFTransaction
import LFWalletAddress
import LFBank

struct CryptoChartDetailView: View {
  @StateObject private var viewModel: CryptoChartDetailViewModel
  
  var filterOptionSubject: CurrentValueSubject<CryptoFilterOption, Never>
  var chartOptionSubject: CurrentValueSubject<ChartOption, Never>
  
  init(
    filterOptionSubject: CurrentValueSubject<CryptoFilterOption, Never>,
    chartOptionSubject: CurrentValueSubject<ChartOption, Never>,
    account: LFAccount?
  ) {
    self.filterOptionSubject = filterOptionSubject
    self.chartOptionSubject = chartOptionSubject
    _viewModel = .init(wrappedValue: CryptoChartDetailViewModel(account: account))
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
      .defaultToolBar(navigationTitle: LFUtility.cardName)
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .addMoney:
          MoveMoneyAccountView(kind: .receive)
        case .send:
          MoveCryptoInputView(type: .sendCrypto)
        case .receive:
          ReceiveCryptoView(account: viewModel.account)
        case .buy:
          MoveCryptoInputView(type: .buyCrypto)
        case .sell:
          MoveCryptoInputView(type: .sellCrypto)
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
      selectInfoCell(title: LFLocalizable.CryptoChartDetail.Open.title, value: viewModel.openPrice)
      selectInfoCell(title: LFLocalizable.CryptoChartDetail.Close.title, value: viewModel.closePrice)
      selectInfoCell(title: LFLocalizable.CryptoChartDetail.High.title, value: viewModel.highPrice)
      selectInfoCell(title: LFLocalizable.CryptoChartDetail.Low.title, value: viewModel.lowPrice)
      selectInfoCell(title: LFLocalizable.CryptoChartDetail.Volume.title, value: viewModel.volumePrice)
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
        .foregroundColor(Colors.primary.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: 30))
      HStack(spacing: 8) {
        Text(LFLocalizable.CryptoChartDetail.Change.title)
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
        .frame(width: 112)
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
        
        HStack(spacing: 10) {
          iconTextButton(title: LFLocalizable.CryptoChartDetail.Buy.title, image: GenImages.CommonImages.buy.swiftUIImage) {
            viewModel.buyButtonTapped()
          }
          iconTextButton(title: LFLocalizable.CryptoChartDetail.Sell.title, image: GenImages.CommonImages.sell.swiftUIImage) {
            viewModel.sellButtonTapped()
          }
          iconTextButton(title: LFLocalizable.CryptoChartDetail.Transfer.title, image: GenImages.CommonImages.transfer.swiftUIImage) {
            viewModel.transferButtonTapped()
          }
        }
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
      case .failure:
        EmptyView()
      }
    }
  }
  
  var priceView: some View {
    HStack(spacing: 8) {
      Text(viewModel.cryptoPrice.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2))
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
      Text(LFLocalizable.CryptoChartDetail.Today.title)
        .foregroundColor(Colors.whiteText.swiftUIColor.opacity(0.5))
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
  }
  
  var disclosure: some View {
    Text(LFLocalizable.Zerohash.Disclosure.description)
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .font(Fonts.regular.swiftUIFont(size: 10))
      .padding(.horizontal, 20)
      .multilineTextAlignment(.center)
  }
  
  var transferBalancePopup: some View {
    LiquidityAlert(
      title: LFLocalizable.CryptoChartDetail.TransferBalance.title,
      message: .empty,
      primary: .init(text: LFLocalizable.Button.Ok.title.uppercased()) {
        viewModel.clearPopup()
      }
    )
  }
  
  @ViewBuilder func buildFor(item: CryptoChartDetailViewModel.SheetPresentation) -> some View {
    switch item {
    case let .trxDetail(model):
      TransactionDetailView(
        accountID: viewModel.accountDataManager.cryptoAccountID,
        transactionId: model.id,
        kind: model.detailType
      )
      .embedInNavigation()
    case .wallet:
      ReceiveCryptoView(account: viewModel.account)
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
      Text(LFLocalizable.CryptoChartDetail.TransferCoin.title(LFUtility.cryptoCurrency).uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.vertical, 14)
      transferCell(with: GenImages.CommonImages.sell.swiftUIImage, and: LFLocalizable.CryptoChartDetail.Send.title) {
        viewModel.sendButtonTapped()
      }
      transferCell(with: GenImages.CommonImages.buy.swiftUIImage, and: LFLocalizable.CryptoChartDetail.Receive.title) {
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
