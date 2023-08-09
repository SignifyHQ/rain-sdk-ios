import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct TransactionRowLoadingView: View {
  var body: some View {
    VStack {
      Spacer()
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding(.leading, 12)
    .padding(.trailing, 16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(12)
  }
}
