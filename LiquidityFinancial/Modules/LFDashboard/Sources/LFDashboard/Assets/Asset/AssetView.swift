import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct AssetView: View {
  @StateObject private var viewModel: AssetViewModel

  init() {
    _viewModel = .init(
      wrappedValue: .init()
    )
  }

  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
  }

  private var content: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 10) {
        balance
        priceView
        HStack(spacing: 10) {
          iconTextButton(title: LFLocalizable.AssetView.Buy.title, image: GenImages.CommonImages.buy) {
            // TODO: buy crypto
          }
          iconTextButton(title: LFLocalizable.AssetView.Sell.title, image: GenImages.CommonImages.sell) {
            // TODO: sell crypto
          }
          iconTextButton(title: LFLocalizable.AssetView.Transfer.title, image: GenImages.CommonImages.transfer) {
            // TODO: Transfer
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
