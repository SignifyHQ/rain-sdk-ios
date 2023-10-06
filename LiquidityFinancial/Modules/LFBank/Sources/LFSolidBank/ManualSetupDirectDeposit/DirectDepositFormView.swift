import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import LFServices

struct DirectDepositFormView: View {
  @State private var isNavigateToEnterEmployerName = false
  @Binding var achInformation: ACHModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(LFLocalizable.DirectDeposit.Form.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 15)
      Text(LFLocalizable.DirectDeposit.Form.description)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .lineSpacing(1.7)
        .multilineTextAlignment(.leading)
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: false
      ) {
        isNavigateToEnterEmployerName = true
      }
      .padding(.bottom, 16)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $isNavigateToEnterEmployerName) {
      EnterEmployerNameView(achInformation: $achInformation)
    }
    .track(name: String(describing: type(of: self)))
  }
}
