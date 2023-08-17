import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct EnterAmountView: View {
  @FocusState private var keyboardFocus: Bool
  @StateObject var viewModel: ManualSetupViewModel
  @State private var isNavigateToSignatureView = false
  
  var body: some View {
    VStack {
      Spacer()
      CurrencyTextFieldView(
        fontSize: 50,
        fontColor: Colors.label,
        placeHolderText: Constants.Default.currencyDefaultAmount.rawValue,
        value: $viewModel.paycheckAmount,
        textAlignment: .trailing
      )
      .padding(.top, 40)
      .multilineTextAlignment(.center)
      .frame(width: 100, height: 50)
      .padding(.bottom, 30)
      .task {
        keyboardFocus = true
      }
      .focused($keyboardFocus)
      Spacer()
      FullSizeButton(title: LFLocalizable.Button.Continue.title, isDisable: viewModel.isDisableAmountContinueButton) {
        isNavigateToSignatureView = true
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .navigationBarTitleDisplayMode(.inline)
    .background(Colors.background.swiftUIColor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(LFLocalizable.DirectDeposit.Toolbal.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
    }
    .navigationLink(isActive: $isNavigateToSignatureView) {
      AddSignatureView(viewModel: viewModel)
    }
    // .track(name: String(describing: type(of: self))) TODO: Will be implemented later
  }
}
