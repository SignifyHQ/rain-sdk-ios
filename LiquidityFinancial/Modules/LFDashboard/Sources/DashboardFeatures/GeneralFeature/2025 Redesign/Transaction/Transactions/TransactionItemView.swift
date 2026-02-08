import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Factory
import Services

public struct TransactionItemView: View {
  @Injected(\.analyticsService) var analyticsService
  
  let transaction: TransactionModel
  let isShowingMerchantCurrency: Bool
  let action: () -> Void
  
  public init(
    transaction: TransactionModel,
    isShowingMerchantCurrency: Bool = false,
    action: @escaping () -> Void
  ) {
    self.transaction = transaction
    self.isShowingMerchantCurrency = isShowingMerchantCurrency
    self.action = action
  }
  
  public var body: some View {
    Button {
      analyticsService.track(event: AnalyticsEvent(name: .viewedTransactionDetail))
      action()
    } label: {
      contentView
    }
  }
}

extension TransactionItemView {
  var contentView: some View {
    VStack(spacing: 12) {
      HStack(alignment: .center, spacing: 12) {
        transactionIconView
        
        VStack(alignment: .leading, spacing: 4) {
          Text(transaction.typeDisplay)
            .foregroundColor(Colors.textPrimary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          if let status = transaction.status {
            Text(status == .completed ? transaction.completedDateTime : status.localizedDescription())
              .foregroundColor(transaction.statusColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          }
        }
        
        Spacer()
        
        VStack(
          alignment: .trailing,
          spacing: 2
        ) {
          Text(transaction.amountFormatted)
            .foregroundColor(Colors.textPrimary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          if isShowingMerchantCurrency,
             let formattedLocalAmount = transaction.localAmountFormatted {
            Text(formattedLocalAmount)
              .foregroundColor(Colors.textSecondary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          }
        }
      }
      .padding(.top, 12)
      
      lineView
    }
  }
  
  var transactionIconView: some View {
    let transactionImageUrlString = transaction.enrichedMerchantIcon
    let transactionImageUrl = URL(string: transactionImageUrlString ?? .empty)
    
    return CachedAsyncImage(
      url: transactionImageUrl
    ) { image in
      image
        .resizable()
        .interpolation(.high)
        .frame(32)
        .clipShape(Circle())
    } placeholder: {
      (transaction.cryptoIconImage ?? transaction.transactionRowImage)?
        .resizable()
        .frame(32)
    }
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
