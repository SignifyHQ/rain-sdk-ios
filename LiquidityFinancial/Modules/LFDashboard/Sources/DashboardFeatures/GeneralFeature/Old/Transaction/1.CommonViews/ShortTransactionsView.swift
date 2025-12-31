import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct ShortTransactionsView: View {
  @Binding var transactions: [TransactionModel]
  
  let title: String
  let onTapTransactionCell: @MainActor (TransactionModel) -> Void
  let seeAllAction: () -> Void
  let filterTapped: ((_ type: TransactionFilterButtonType) -> Void)?
  let appliedFilters: [TransactionFilterButtonType: Int]
  
  public init(
    transactions: Binding<[TransactionModel]>,
    title: String,
    onTapTransactionCell: @escaping @MainActor (TransactionModel) -> Void,
    seeAllAction: @escaping () -> Void,
    filterTapped: ((_ type: TransactionFilterButtonType) -> Void)? = nil,
    appliedFilters: [TransactionFilterButtonType: Int] = [:]
  ) {
    _transactions = transactions
    self.title = title
    self.onTapTransactionCell = onTapTransactionCell
    self.seeAllAction = seeAllAction
    self.filterTapped = filterTapped
    self.appliedFilters = appliedFilters
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if transactions.isNotEmpty || areFiltersApplied {
        HStack(alignment: .bottom) {
          Text(title)
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          
          Spacer()
          
          seeAllTransactions
            .foregroundColor(Colors.label.swiftUIColor)
        }
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        
        HStack {
          ForEach(TransactionFilterButtonType.allCases) { type in
            filterButton(type: type)
          }
        }
      }
      
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
        Text(L10N.Common.AssetView.seeAll)
        GenImages.CommonImages.icRightArrow.swiftUIImage
      }
      .frame(height: 30, alignment: .bottom)
    }
  }
  
  func filterButton(
    type: TransactionFilterButtonType
  ) -> some View {
    Button(
      action: {
        filterTapped?(type)
      }, label: {
        if let image = type.image {
          image
        }
        
        if let title = type.title {
          HStack {
            if let appliedFiltersCount = appliedFilters[type],
               appliedFiltersCount > 0 {
              Text("\(title) (\(appliedFiltersCount))")
            } else {
              Text(title)
            }
            
            GenImages.CommonImages.icArrowDown.swiftUIImage
          }
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        }
      }
    )
    .frame(height: 40, alignment: .center)
    .padding(.horizontal, 8)
    .background(
      Colors.buttons.swiftUIColor
    )
    .foregroundColor(Colors.label.swiftUIColor)
    .cornerRadius(10)
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
          Text(L10N.Common.CashTab.NoTransactionYet.title)
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

private extension ShortTransactionsView {
  var areFiltersApplied: Bool {
    appliedFilters.values.reduce(0, +) > 0
  }
}
