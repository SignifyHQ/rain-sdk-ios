import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services

struct DonationTransactionReceiptView: View {
  @State var openSafariType: DonationTransactionReceiptViewModel.OpenSafariType?
  @StateObject private var viewModel: DonationTransactionReceiptViewModel
  
  private let receipt: DonationReceipt
  private let charityEIN = "83-1352270"
  private let donationAddress = "10573 West Pico Blvd. #186, Los Angeles, CA 90064-2348"

  init(accountID: String, receipt: DonationReceipt) {
    _viewModel = .init(wrappedValue: DonationTransactionReceiptViewModel(accountID: accountID, receipt: receipt))
    self.receipt = receipt
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
      }
      footerView
        .ignoresSafeArea()
    }
    .padding(.top, 36)
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .defaultToolBar(navigationTitle: L10N.Common.DonationReceipt.Navigation.title)
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
private extension DonationTransactionReceiptView {
  func openLink(value: String) {
    if let url = URL(string: value.trimWhitespacesAndNewlines()) {
      openSafariType = .disclosure(url)
    }
  }
  
  var footerView: some View {
    VStack(spacing: 16) {
      Text(L10N.Common.DonationReceipt.Fundraiser.title(receipt.fundraiserName))
      Text(L10N.Common.DonationReceipt.Charity.title(receipt.charityName, charityEIN))
      links
      Text(donationAddress)
    }
    .multilineTextAlignment(.center)
    .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    .foregroundColor(Colors.label.swiftUIColor)
    .padding(.horizontal, 30)
    .padding(.vertical, 24)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
  
  private var links: some View {
    let terms = L10N.Common.DonationReceipt.Terms.title
    let privacy = L10N.Common.DonationReceipt.Privacy.title
    let text = "\(terms) | \(privacy)"
    let titleParagraphStyle = NSMutableParagraphStyle()
    titleParagraphStyle.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
      .font: Fonts.regular.font(size: Constants.FontSize.ultraSmall.value),
      .foregroundColor: Colors.label.color,
      .paragraphStyle: titleParagraphStyle
    ]
    let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    return TextTappable(
      attributedText: attributedText,
      links: [terms, privacy],
      style: .underlined(Colors.label.color)
    ) { text in
      if text == terms {
        openLink(value: LFUtilities.termsURL)
      } else if text == privacy {
        openLink(value: LFUtilities.privacyURL)
      }
    }
    .frame(height: 16)
  }
}
