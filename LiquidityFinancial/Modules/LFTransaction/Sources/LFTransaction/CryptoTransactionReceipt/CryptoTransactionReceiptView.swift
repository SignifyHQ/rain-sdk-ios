import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CryptoTransactionReceiptView: View {
  @Environment(\.openURL) private var openURL
  @StateObject private var viewModel: CryptoTransactionReceiptViewModel
  
  init(accountID: String, receipt: CryptoReceipt) {
    _viewModel = .init(wrappedValue: CryptoTransactionReceiptViewModel(accountID: accountID, receipt: receipt))
  }
  
  var body: some View {
    VStack {
      ScrollView {
        VStack(spacing: 16) {
          ForEach(viewModel.receiptData, id: \.self) { item in
            HStack {
              TransactionReceiptCell(data: item)
            }
          }
          .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 30)
        footerView
          .padding(.top, 32)
      }
    }
    .padding(.top, 36)
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .defaultToolBar(navigationTitle: LFLocalizable.CryptoReceipt.Navigation.title)
  }
}

// MARK: - View Components
private extension CryptoTransactionReceiptView {
  func openLink(value: String) {
    if let url = URL(string: value.trimWhitespacesAndNewlines()) {
      openURL(url)
    }
  }
  
  var footerView: some View {
    VStack(spacing: 20) {
      firstSectionView
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      secondSectionView
    }
    .padding(.vertical, 20)
    .background(Colors.buttons.swiftUIColor.edgesIgnoringSafeArea(.bottom))
    .cornerRadius(15, corners: [.topLeft, .topRight])
  }
  
  var firstSectionView: some View {
    VStack(spacing: 30) {
      HStack(spacing: 4) {
        TextTappable(
          text: LFLocalizable.CryptoReceipt.CardType.link,
          textAlignment: .center,
          links: [LFLocalizable.CryptoReceipt.CardType.link],
          openLink: openLink(value:)
        )
        .frame(maxWidth: 136)
        Rectangle()
          .frame(width: 1, height: 20)
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.trailing, 6)
        Text(LFLocalizable.CryptoReceipt.Phonenumber.link)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.horizontal, 16)
      .ignoresSafeArea(.keyboard, edges: .bottom)
      TextTappable(
        text: LFLocalizable.CryptoReceipt.Zerohash.description,
        textAlignment: .center,
        links: [LFLocalizable.CryptoReceipt.Zerohash.link],
        openLink: openLink(value:)
      )
    }
  }
  
  var secondSectionView: some View {
    VStack(spacing: 16) {
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.Cancellation.title.uppercased(),
        attributedText: LFLocalizable.CryptoReceipt.Cancellation.description
      )
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.Liability.title.uppercased(),
        attributedText: LFLocalizable.CryptoReceipt.Liability.description.localizedString
      )
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.Beware.title.uppercased(),
        attributedText: LFLocalizable.CryptoReceipt.Beware.description,
        links: [LFLocalizable.CryptoReceipt.ConsumerTools.link]
      )
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.PriceRisk.title.uppercased(),
        attributedText: LFLocalizable.CryptoReceipt.PriceRisk.description
      )
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.Illinois.title,
        attributedText: LFLocalizable.CryptoReceipt.Illinois.description,
        links: [LFLocalizable.CryptoReceipt.IllinoisCustomer.link]
      )
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.MaineCustomers.title,
        attributedText: LFLocalizable.CryptoReceipt.MaineCustomers.description,
        links: [LFLocalizable.CryptoReceipt.MaineCustomer.link]
      )
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.MinnesotaCustomers.title,
        attributedText: LFLocalizable.CryptoReceipt.MinnesotaCustomers.description,
        links: [
          LFLocalizable.CryptoReceipt.MinnesotaCustomerFraud.link,
          LFLocalizable.CryptoReceipt.MinnesotaCustomerCryptocurrency.link
        ]
      )
      textLabelTappableCell(
        title: LFLocalizable.CryptoReceipt.TexasCustomers.title,
        attributedText: LFLocalizable.CryptoReceipt.TexasCustomers.description,
        links: [LFLocalizable.CryptoReceipt.TexasCustomer.link]
      )
    }
  }
  
  func textLabelTappableCell(title: String, attributedText: String, links: [String] = []) -> some View {
    VStack(spacing: 0) {
      Text(title)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
        .fixedSize(horizontal: false, vertical: true)
      TextTappable(
        text: attributedText,
        textAlignment: .center,
        links: links,
        openLink: openLink(value:)
      )
      .padding(.horizontal, 16)
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
}
