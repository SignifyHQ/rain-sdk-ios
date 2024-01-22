import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct ShortTransactionsView: View {
  @Binding var transactions: [TransactionModel]
  let title: String
  let onTapTransactionCell: @MainActor (TransactionModel) -> Void
  let seeAllAction: () -> Void
  
  public init(
    transactions: Binding<[TransactionModel]>,
    title: String,
    onTapTransactionCell: @escaping @MainActor (TransactionModel) -> Void,
    seeAllAction: @escaping () -> Void
  ) {
    _transactions = transactions
    self.title = title
    self.onTapTransactionCell = onTapTransactionCell
    self.seeAllAction = seeAllAction
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .bottom) {
        Text(title)
          .opacity(transactions.isEmpty ? 0 : 1)
        Spacer()
        seeAllTransactions
          .opacity(transactions.isEmpty ? 0 : 1)
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      if transactions.isEmpty {
        noTransactionsYetView
      } else {
        ForEach(transactions) { transaction in
          TransactionRowView(item: transaction) {
            onTapTransactionCell(transaction)
          }
        }
      }
    }
  }
}

// MARK: - View Components
private extension ShortTransactionsView {
  var seeAllTransactions: some View {
    Button {
      seeAllAction()
    } label: {
      HStack(spacing: 8) {
        Text(LFLocalizable.AssetView.seeAll)
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .frame(height: 30, alignment: .bottom)
    }
  }
  
  var noTransactionsYetView: some View {
    VStack {
      Spacer()
        .frame(minHeight: UIScreen.main.bounds.size.height * 0.12)
      HStack {
        Spacer()
        VStack(spacing: 8) {
          GenImages.CommonImages.icSearch.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          Text(LFLocalizable.CashTab.NoTransactionYet.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        }
        Spacer()
      }
      Spacer()
        .frame(minHeight: UIScreen.main.bounds.size.height * 0.12)
    }
  }
}
