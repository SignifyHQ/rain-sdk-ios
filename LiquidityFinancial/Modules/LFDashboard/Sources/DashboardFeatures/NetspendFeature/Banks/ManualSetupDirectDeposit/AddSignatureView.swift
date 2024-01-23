import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import Factory

struct AddSignatureView: View {
  @StateObject var viewModel: ManualSetupViewModel
  @State private var isNavigateToSignatureView = false
  @Injected(\.analyticsService) var analyticsService
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(L10N.Common.DirectDeposit.AddSignature.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.leading)
        .padding(.top, 16)
      Text(L10N.Common.DirectDeposit.AddSignature.description)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
        .lineSpacing(2)
      Spacer()
      FullSizeButton(title: L10N.Common.DirectDeposit.AddSignature.buttonTitle, isDisable: false) {
        isNavigateToSignatureView = true
      }
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $isNavigateToSignatureView) {
      SignatureView(viewModel: viewModel)
    }
    .onAppear(perform: {
      analyticsService.track(event: AnalyticsEvent(name: .viewsDirectDepositReady))
    })
    .track(name: String(describing: type(of: self)))
  }
}
