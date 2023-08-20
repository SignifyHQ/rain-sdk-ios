import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct DonationTransactionDetailView: View {
  @State private var isNavigateToReceiptView = false
  let transaction: TransactionModel
  
  public init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
      .navigationLink(isActive: $isNavigateToReceiptView) {
        EmptyView() // TODO: - Will be replaced by ReceiptView
      }
  }
}

// MARK: - View Components
private extension DonationTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      TransactionCardView(information: cardInformation)
      FullSizeButton(
        title: LFLocalizable.TransactionDetail.Receipt.button,
        isDisable: false,
        type: .secondary
      ) {
        isNavigateToReceiptView = true
      }
    }
  }
}

// MARK: - View Helpers
private extension DonationTransactionDetailView {
  var cardInformation: TransactionCardInformation {
    TransactionCardInformation(
      title: LFLocalizable.TransactionCard.Donation.title,
      amount: amountValue,
      message: transaction.rewards?.description ?? .empty,
      activityItem: "", // TODO: Will be implemented in Donation Ticket
      image: GenImages.CommonImages.zerohash.swiftUIImage, // TODO: Will be implemented in Donation Ticket
      backgroundColor: Colors.donationCardBackground.swiftUIColor // TODO: Will be implemented in Donation Ticket
    )
  }
  
  var amountValue: String {
    transaction.amount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2)
  }
}
