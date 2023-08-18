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
    }
  }
}
