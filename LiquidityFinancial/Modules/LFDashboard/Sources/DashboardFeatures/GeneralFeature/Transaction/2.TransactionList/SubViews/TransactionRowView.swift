import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Factory
import Services

public struct TransactionRowView: View {
  @Injected(\.analyticsService) var analyticsService
  
  let item: TransactionModel
  let action: () -> Void

  public init(item: TransactionModel, action: @escaping () -> Void) {
    self.item = item
    self.action = action
  }
  
  public var body: some View {
    Button {
      analyticsService.track(event: AnalyticsEvent(name: .viewedTransactionDetail))
      action()
    } label: {
      HStack(spacing: 10) {
        transactionImage
        center
        Spacer()
        trailing
      }
      .padding(.leading, 12)
      .padding(.trailing, 16)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(12)
    }
  }
}

// MARK: - View Components
private extension TransactionRowView {
  var transactionImage: some View {
    Image(item.type.assetName, bundle: .main)
      .frame(46)
      .padding(.vertical, 12)
  }

  var center: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(item.titleDisplay)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.7)
        .allowsTightening(true)
        .lineLimit(2)
      Text(item.subtitle)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineLimit(1)
    }
  }

  var trailing: some View {
    VStack(alignment: .trailing, spacing: 4) {
      Text(item.ammountFormatted)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(item.colorForType)
        .minimumScaleFactor(0.7)
        .allowsTightening(true)
        .lineLimit(1)
      if let balanceFormatted = item.balanceFormatted {
        Text(balanceFormatted)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
    }
  }
}
