import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct DonationTransactionReceiptView: View {
  @Environment(\.openURL) private var openURL
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
    // .track(name: String(describing: type(of: self))) TODO: Will be implemented later
    .navigationBarTitleDisplayMode(.inline)
    .defaultToolBar(navigationTitle: LFLocalizable.DonationReceipt.Navigation.title)
  }
}

// MARK: - View Components
private extension DonationTransactionReceiptView {
  func openLink(value: String) {
    if let url = URL(string: value.trimWhitespacesAndNewlines()) {
      openURL(url)
    }
  }
  
  var footerView: some View {
    VStack(spacing: 16) {
      Text(LFLocalizable.DonationReceipt.Fundraiser.title(receipt.fundraiserName))
      Text(LFLocalizable.DonationReceipt.Charity.title(receipt.charityName, charityEIN))
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
    let terms = LFLocalizable.DonationReceipt.Terms.title
    let privacy = LFLocalizable.DonationReceipt.Privacy.title
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
        openLink(value: LFUtility.termsURL)
      } else if text == privacy {
        openLink(value: LFUtility.privacyURL)
      }
    }
    .frame(height: 16)
  }
}
