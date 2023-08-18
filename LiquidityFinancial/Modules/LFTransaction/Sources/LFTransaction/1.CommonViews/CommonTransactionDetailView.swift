import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CommonTransactionDetailView<Content: View>: View {
  let transaction: TransactionModel
  @ViewBuilder let content: Content?
  
  init(transaction: TransactionModel, content: Content? = EmptyView()) {
    self.transaction = transaction
    self.content = content
  }
  
  var body: some View {
    VStack(spacing: 24) {
      headerTitle
      amountView
      if let content = content {
        content
      }
      Spacer()
    }
    .defaultToolBar(
      icon: .intercom,
      navigationTitle: transaction.title?.capitalized,
      openIntercom: {}
    )
    .frame(maxWidth: .infinity)
    .navigationBarTitleDisplayMode(.inline)
    .padding([.top, .horizontal], 30)
    .padding(.bottom, 20)
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: View Components
private extension CommonTransactionDetailView {
  var headerTitle: some View {
    VStack(spacing: 8) {
      Text(transaction.descriptionDisplay.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      Text(transaction.transactionDateInLocalZone(includeYear: true))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
        .font(Fonts.regular.swiftUIFont(size: 10))
    }
  }
  
  var amountView: some View {
    VStack(spacing: 14) {
      HStack(spacing: 4) {
        Text(amountValue)
          .font(Fonts.medium.swiftUIFont(size: 40))
          .foregroundColor(transaction.colorForType)
        if transaction.isCryptoTransaction {
          GenImages.Images.icCoin.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      if transaction.currentBalance != nil {
        Text(LFLocalizable.TransactionDetail.BalanceCash.title(balanceValue))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
      }
    }
  }
}

// MARK: View Helpers
private extension CommonTransactionDetailView {
  var amountValue: String {
    transaction.amount.formattedAmount(
      prefix: transaction.isCryptoTransaction ? nil : Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: 2
    )
  }
  
  var balanceValue: String {
    transaction.currentBalance?.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: 2
    ) ?? .empty
  }
}
