import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct AssetView: View {
  @StateObject private var viewModel: AssetViewModel

  init(guestHandler: @escaping () -> Void) {
    _viewModel = .init(
      wrappedValue: .init(guestHandler: guestHandler)
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
          BuySellCryptoInputView(type: .buyCrypto)
        case .sellCrypto:
          BuySellCryptoInputView(type: .sellCrypto)
        case .receive:
          ReceiveCryptoView(account: viewModel.account)
        }
      }
      .sheet(item: $viewModel.sheet) { item in
        switch item {
        case .wallet:
          ReceiveCryptoView(account: viewModel.account)
            .embedInNavigation()
        }
      }
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.onAppear()
      }
  }

  private var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 10) {
        balance
        priceView
        BalanceAlertView(type: .crypto, hasContacts: true, cryptoBalance: viewModel.cryptoBalance.asDouble) {
          viewModel.walletRowTapped()
        }
        HStack(spacing: 10) {
          iconTextButton(
            title: LFLocalizable.AssetView.Buy.title,
            image: GenImages.CommonImages.buy
          ) {
            viewModel.onClickedBuyButton()
          }
          iconTextButton(
            title: LFLocalizable.AssetView.Sell.title,
            image: GenImages.CommonImages.sell
          ) {
            viewModel.onClickedSellButton()
          }
          iconTextButton(
            title: LFLocalizable.AssetView.Transfer.title,
            image: GenImages.CommonImages.transfer
          ) {
            viewModel.transferButtonTapped()
          }
        }
        .padding(.top, 6)
        ArrowButton(
          image: GenImages.CommonImages.walletAddress,
          title: LFLocalizable.AssetView.walletAddress,
          value: Constants.Default.walletAddressPlaceholder.rawValue
        ) {
          // TODO: Wallet address Tapped
        }
        activity
        disclosure
          .padding(.top, 2)
        Spacer()
      }
      .padding(.top, 20)
      .padding(.horizontal, 30)
    }
  }

  private var activity: some View {
    Group {
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
    }
  }

  private var balance: some View {
    VStack(alignment: .center, spacing: 4) {
      HStack(alignment: .center, spacing: 4) {
        Text(viewModel.cryptoBalance.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3))
          .foregroundColor(Colors.primary.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: 32))
        GenImages.Images.icCrypto.swiftUIImage
          .foregroundColor(Colors.primary.swiftUIColor)
      }
      Text(
        viewModel.usdBalance.formattedAmount(
          prefix: Constants.CurrencyUnit.usd.symbol,
          minFractionDigits: Constants.CurrencyUnit.usd.maxFractionDigits
        ))
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

  private var priceView: some View {
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

  private var disclosure: some View {
    Text(LFLocalizable.AssetView.disclosure)
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .font(Fonts.bold.swiftUIFont(size: 10))
      .padding(.horizontal, 20)
      .multilineTextAlignment(.center)
  }

  private var seeAllTransactions: some View {
    Button {
      // TODO: See all transactions
    } label: {
      HStack(spacing: 8) {
        Text(LFLocalizable.AssetView.seeAll)
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .frame(height: 30, alignment: .bottom)
    }
  }

  private func iconTextButton(title: String, image: ImageAsset, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      VStack(spacing: 6) {
        image.swiftUIImage
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

}

private extension AssetView {
  
  private var cryptoTransfer: some View {
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
        with: GenImages.CommonImages.sell,
        and: LFLocalizable.AssetView.Send.title
      ) {
        // TODO: send button tapped
      }
      transferCell(
        with: GenImages.CommonImages.buy,
        and: LFLocalizable.AssetView.Receive.title
      ) {
        viewModel.receiveButtonTapped()
      }
      Spacer()
    }
    .padding(.horizontal, 30)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
  
  private func transferCell(with image: ImageAsset, and title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        image.swiftUIImage
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
