import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct DonationTransactionDetailView: View {
  @Environment(\.openURL) var openURL
  @StateObject private var viewModel = DonationTransactionDetailViewModel()
  let donation: DonationModel
  
  public init(donation: DonationModel) {
    self.donation = donation
  }
  
  public var body: some View {
    VStack(spacing: 24) {
      headerTitle
      amountView
      TransactionCardView(information: cardInformation)
      Spacer()
      StatusView(donationStatus: donation.status)
      disclosureView
    }
    .scrollOnOverflow()
    .defaultToolBar(
      icon: .support,
      navigationTitle: LFLocalizable.TransactionCard.Donation.title,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .frame(maxWidth: .infinity)
    .navigationBarTitleDisplayMode(.inline)
    .padding([.top, .horizontal], 30)
    .padding(.bottom, 12)
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension DonationTransactionDetailView {
  var headerTitle: some View {
    VStack(spacing: 8) {
      Text(donation.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      Text(donation.transactionDateInLocalZone(includeYear: true))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
        .font(Fonts.regular.swiftUIFont(size: 10))
    }
  }
  
  var amountView: some View {
    VStack(spacing: 14) {
      Text(amountValue)
        .font(Fonts.medium.swiftUIFont(size: 40))
        .foregroundColor(Colors.green.swiftUIColor)
      Text(LFLocalizable.TransactionDetail.TotalDonated.title(totalDonation))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
    }
  }
  
  @ViewBuilder
  var disclosureView: some View {
    if viewModel.isDonationsCard {
      TextTappable(
        text: viewModel.disclosureString,
        textColor: Colors.label.color.withAlphaComponent(0.6),
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [viewModel.termsLink]
      ) { tappedString in
        guard let url = viewModel.getUrl(for: tappedString) else { return }
        openURL(url)
      }
      .frame(height: 200)
    }
  }
}

// MARK: - View Helpers
private extension DonationTransactionDetailView {
  var cardInformation: TransactionCardInformation {
    TransactionCardInformation(
      cardType: .donation,
      amount: amountValue,
      rewardAmount: amountValue,
      message: donation.message,
      activityItem: "", // TODO: Will be implemented in Donation Ticket
      stickerUrl: donation.stickerURL,
      color: donation.backgroundColor
    )
  }
  
  var amountValue: String {
    donation.amount.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits
    )
  }

  var totalDonation: String {
    donation.totalDonation.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: 2
    )
  }
}
