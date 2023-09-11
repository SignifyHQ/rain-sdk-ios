import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

public struct RewardTransactionRow: View {
  let item: RewardTransactionRowModel
  let action: (() -> Void)?
  
  public init(item: RewardTransactionRowModel, action: (() -> Void)? = nil) {
    self.item = item
    self.action = action
  }
  
  public var body: some View {
    Button {
      action?()
    } label: {
      HStack(spacing: 10) {
        transactionImage
        center
        Spacer()
        trailing
      }
      .padding(.leading, 12)
      .padding(.trailing, 16)
      .padding(.vertical, 14)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(12)
    }
    .frame(height: 70)
  }
}

  // MARK: - View Components
private extension RewardTransactionRow {
  @ViewBuilder var transactionImage: some View {
    if let stickerUrl = item.stickerUrl {
      CachedAsyncImage(url: URL(string: stickerUrl)) { image in
        image
          .resizable()
          .scaledToFill()
          .clipShape(Circle())
          .overlay(Circle().stroke(Colors.contrast.swiftUIColor, lineWidth: 6))
      } placeholder: {
        Image(item.assetName, bundle: .main)
          .frame(46)
          .padding(.vertical, 12)
      }
      .frame(46)
    }
  }
  
  var center: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(item.titleDisplay)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.7)
        .allowsTightening(true)
        .lineLimit(2)
      Text(item.subtitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
        .lineLimit(1)
    }
  }
  
  var trailing: some View {
    VStack(alignment: .trailing, spacing: 4) {
      Text(item.ammountFormatted )
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(amountColor)
        .minimumScaleFactor(0.7)
        .allowsTightening(true)
        .lineLimit(1)
    }
  }
  
  var amountColor: Color {
    switch item.status {
    case .pending:
      return Colors.pending.swiftUIColor
    default:
      return Colors.green.swiftUIColor
    }
  }
}
