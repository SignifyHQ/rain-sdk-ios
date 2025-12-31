import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct TransactionReceiptCell: View {
  let data: TransactionRowData
  
  init(data: TransactionRowData) {
    self.data = data
  }
  
  var body: some View {
    VStack(spacing: 16) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      HStack(spacing: 4) {
        Text(data.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .padding(.trailing, 12)
        Spacer()
        if let markValue = data.markValue?.uppercased() {
          Text(markValue)
            .minimumScaleFactor(0.8)
            .foregroundColor(Colors.primary.swiftUIColor)
            .allowsTightening(true)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        }
        if let value = data.value {
          Text(data.shouldUppercase ? value.uppercased() : value)
            .foregroundColor(Colors.label.swiftUIColor)
            .minimumScaleFactor(0.8)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        }
      }
    }
  }
}
