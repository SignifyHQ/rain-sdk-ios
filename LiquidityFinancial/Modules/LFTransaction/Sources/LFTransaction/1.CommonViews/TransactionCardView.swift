import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

struct TransactionCardView: View {
  @State private var isPresentShareSheetView = false
  let information: TransactionCardInformation
  
  var body: some View {
    VStack(spacing: 4) {
      headerTitle
      imageView
      message
      FullSizeButton(
        title: LFLocalizable.TransactionCard.Share.title,
        isDisable: true,
        textColor: Colors.darkText.swiftUIColor,
        backgroundColor: Colors.whiteText.swiftUIColor
      ) {
        // Temporarily hidden
      }
      .padding(.top, 12)
    }
    .onTapGesture {
      isPresentShareSheetView = true
    }
    .sheet(isPresented: $isPresentShareSheetView) {
      ShareSheetView(activityItems: [information.activityItem])
    }
    .padding(.vertical, 40)
    .background(information.backgroundColor)
    .cornerRadius(32)
  }
}

// MARK: - View Components
private extension TransactionCardView {
  var headerTitle: some View {
    VStack(spacing: 8) {
      Text(information.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
      Text(information.amount)
        .font(Fonts.bold.swiftUIFont(size: 32))
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
  
  var imageView: some View {
    ZStack {
      LottieView(twinkle: .contrast)
        .frame(height: 160)
      information.image
        .resizable()
        .scaledToFit()
    }
  }
  
  var message: some View {
    Text(information.message)
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.contrast.swiftUIColor)
      .lineSpacing(1.33)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, 24)
  }
}
