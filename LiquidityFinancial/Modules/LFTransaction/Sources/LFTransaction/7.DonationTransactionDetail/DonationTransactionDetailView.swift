import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct DonationTransactionDetailView: View {
  @StateObject private var viewModel = DonationTransactionDetailViewModel()
  let transaction: TransactionModel
  
  public init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .receipt(donationReceipt):
          DonationTransactionReceiptView(accountID: transaction.accountId, receipt: donationReceipt)
        }
      }
  }
}

// MARK: - View Components
private extension DonationTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      TransactionCardView(information: cardInformation)
      if let donationReceipt = transaction.donationReceipt {
        FullSizeButton(
          title: LFLocalizable.TransactionDetail.Receipt.button,
          isDisable: false,
          type: .secondary
        ) {
          viewModel.goToReceiptScreen(receipt: donationReceipt)
        }
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
