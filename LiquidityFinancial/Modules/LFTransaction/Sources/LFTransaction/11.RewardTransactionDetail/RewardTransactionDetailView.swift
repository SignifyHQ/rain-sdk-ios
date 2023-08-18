import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct RewardTransactionDetailView: View {
  let transaction: TransactionModel
  
  public init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
  }
}

// MARK: - View Components
private extension RewardTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      TransactionCardView(information: cardInformation)
      FullSizeButton(
        title: LFLocalizable.TransactionDetail.Receipt.button,
        isDisable: false,
        type: .secondary
      ) {
      }
    }
  }
}

// MARK: - View Helpers
private extension RewardTransactionDetailView {
  var cardInformation: TransactionCardInformation {
    TransactionCardInformation(
      title: LFLocalizable.TransactionCard.Purchase.title(LFUtility.cardName),
      amount: amountValue,
      message: LFLocalizable.TransactionCard.Purchase.message(rewardAmount, amountValue, LFUtility.appName),
      activityItem: LFLocalizable.TransactionCard.ShareCrypto.title(rewardAmount, LFUtility.appName, LFUtility.shareAppUrl),
      image: GenImages.CommonImages.zerohash,
      backgroundColor: Colors.purchaseCardBackground.swiftUIColor
    )
  }
  
  var rewardAmount: String {
    transaction.rewards?.amount?.formattedAmount(minFractionDigits: 3) ?? .empty
  }
  
  var amountValue: String {
    transaction.amount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2)
  }
}
