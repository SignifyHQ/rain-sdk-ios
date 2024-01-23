import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

struct NSSetCardPinView: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject
  private var viewModel: NSSetCardPinViewModel
    
  init(viewModel: NSSetCardPinViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .popup(isPresented: $viewModel.isShowSetPinSuccessPopup) {
        successPopup
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .navigationBarTitleDisplayMode(.inline)
      .adaptToKeyboard()
      .ignoresSafeArea(edges: .bottom)
      .defaultToolBar(icon: .xMark, onDismiss: {
        hideKeyboard()
      })
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension NSSetCardPinView {
  var content: some View {
    VStack(alignment: .leading, spacing: 50) {
      Text(L10N.Common.SetCardPin.Screen.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.top, 16)
      VStack(spacing: 20) {
        PinCodeView(
          code: $viewModel.pinValue,
          isDisabled: $viewModel.isShowIndicator,
          codeLength: viewModel.pinCodeDigits
        )
        Text(L10N.Common.SetCardPin.Screen.description)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
          .padding(.horizontal, 20)
          .lineSpacing(1.7)
      }
      .padding(.horizontal, 16)
      Spacer()
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isPinEntered,
        isLoading: $viewModel.isShowIndicator
      ) {
        hideKeyboard()
        viewModel.onClickedContinueButton()
      }
    }
    .padding([.horizontal, .bottom], 30)
  }
  
  var successPopup: some View {
    LiquidityAlert(
      title: L10N.Common.SetCardPin.Popup.title,
      message: L10N.Common.SetCardPin.Popup.successMessage,
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.handleSuccessPrimaryAction {
          hideKeyboard()
          dismiss()
        }
      },
      secondary: nil
    )
  }
}
