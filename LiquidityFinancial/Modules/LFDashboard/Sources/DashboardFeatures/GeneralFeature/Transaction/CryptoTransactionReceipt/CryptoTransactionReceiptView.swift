import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services

struct CryptoTransactionReceiptView: View {
  @State var openSafariType: CryptoTransactionReceiptViewModel.OpenSafariType?
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
    .defaultToolBar(navigationTitle: L10N.Common.CryptoReceipt.Navigation.title)
    .track(name: String(describing: type(of: self)))
    .fullScreenCover(item: $openSafariType, content: { type in
      switch type {
      case .disclosure(let url):
        SFSafariViewWrapper(url: url)
      }
    })
  }
}

// MARK: - View Components
private extension CryptoTransactionReceiptView {
  func openLink(value: String) {
    if let url = URL(string: value.trimWhitespacesAndNewlines()) {
      openSafariType = .disclosure(url)
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
          text: L10N.Custom.CryptoReceipt.CardType.link,
          textAlignment: .center,
          links: [L10N.Custom.CryptoReceipt.CardType.link],
          openLink: openLink(value:)
        )
        .frame(maxWidth: 136)
        Rectangle()
          .frame(width: 1, height: 20)
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.trailing, 6)
        Text(L10N.Common.CryptoReceipt.Phonenumber.link)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.horizontal, 16)
      .ignoresSafeArea(.keyboard, edges: .bottom)
      TextTappable(
        text: L10N.Common.CryptoReceipt.Zerohash.description,
        textAlignment: .center,
        links: [L10N.Common.CryptoReceipt.Zerohash.link],
        openLink: openLink(value:)
      )
    }
  }
  
  var secondSectionView: some View {
    VStack(spacing: 16) {
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.Cancellation.title.uppercased(),
        attributedText: L10N.Common.CryptoReceipt.Cancellation.description
      )
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.Liability.title.uppercased(),
        attributedText: L10N.Common.CryptoReceipt.Liability.description.localizedString
      )
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.Beware.title.uppercased(),
        attributedText: L10N.Common.CryptoReceipt.Beware.description,
        links: [L10N.Common.CryptoReceipt.ConsumerTools.link]
      )
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.PriceRisk.title.uppercased(),
        attributedText: L10N.Common.CryptoReceipt.PriceRisk.description
      )
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.Illinois.title,
        attributedText: L10N.Common.CryptoReceipt.Illinois.description,
        links: [L10N.Common.CryptoReceipt.IllinoisCustomer.link]
      )
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.MaineCustomers.title,
        attributedText: L10N.Common.CryptoReceipt.MaineCustomers.description,
        links: [L10N.Common.CryptoReceipt.MaineCustomer.link]
      )
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.MinnesotaCustomers.title,
        attributedText: L10N.Common.CryptoReceipt.MinnesotaCustomers.description,
        links: [
          L10N.Common.CryptoReceipt.MinnesotaCustomerFraud.link,
          L10N.Common.CryptoReceipt.MinnesotaCustomerCryptocurrency.link
        ]
      )
      textLabelTappableCell(
        title: L10N.Common.CryptoReceipt.TexasCustomers.title,
        attributedText: L10N.Common.CryptoReceipt.TexasCustomers.description,
        links: [L10N.Common.CryptoReceipt.TexasCustomer.link]
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
