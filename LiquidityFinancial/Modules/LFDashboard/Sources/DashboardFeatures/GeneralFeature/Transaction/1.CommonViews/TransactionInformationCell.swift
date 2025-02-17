import LFLocalizable
import SwiftUI
import LFStyleGuide
import LFUtilities

struct TransactionInformationCell: View {
  let item: TransactionInformation
  
  var body: some View {
    HStack(spacing: 2) {
      Text(item.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      Spacer()
      if let markValue = item.markValue {
        Text(markValue)
          .foregroundColor(Colors.primary.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
      }
      Text(item.value)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .strikethrough(item.title == L10N.Common.CryptoReceipt.Fee.title, color: Colors.label.swiftUIColor)
      if item.title == L10N.Common.CryptoReceipt.Fee.title {
        Text(L10N.Common.TransferView.Status.free)
          .foregroundColor(Colors.green.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
          .padding(.leading, 2)
      }
    }
  }
}
