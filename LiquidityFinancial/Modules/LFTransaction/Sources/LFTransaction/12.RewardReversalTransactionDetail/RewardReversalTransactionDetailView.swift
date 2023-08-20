import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct RewardReversalTransactionDetailView: View {
  @State private var isNavigationToReceipt = false
  
  let transaction: TransactionModel
  let transactionInfos: [TransactionInformation]
  
  public init(transaction: TransactionModel, transactionInfos: [TransactionInformation]) {
    self.transaction = transaction
    self.transactionInfos = transactionInfos
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
  }
}

// MARK: - View Components
private extension RewardReversalTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      ForEach(transactionInfos, id: \.self) { item in
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        TransactionInformationCell(item: item)
      }
      Spacer()
      if let status = transaction.status {
        StatusView(status: status)
      }
      footer
    }
    .navigationLink(isActive: $isNavigationToReceipt) {
      // TODO: - Will be replaced by ReceiptView
      EmptyView()
    }
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      Button {
        isNavigationToReceipt = true
      } label: {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
          title: LFLocalizable.TransactionDetail.Receipt.button,
          value: nil
        )
      }
      Text(LFLocalizable.Zerohash.Disclosure.description)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
}
