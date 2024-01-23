import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

struct NSEnterCVVCodeView: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject 
  private var viewModel: NSEnterCVVCodeViewModel
  
  let screenTitle: String
  let onDissmiss: ((String) -> Void)?
  
  init(
    viewModel: NSEnterCVVCodeViewModel,
    screenTitle: String,
    onDissmiss: @escaping (String) -> Void
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.screenTitle = screenTitle
    self.onDissmiss = onDissmiss
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .adaptToKeyboard()
      .navigationBarTitleDisplayMode(.inline)
      .defaultToolBar(icon: .xMark, onDismiss: {
        hideKeyboard()
      })
      .ignoresSafeArea(edges: .bottom)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension NSEnterCVVCodeView {
  var content: some View {
    VStack(alignment: .leading, spacing: 50) {
      VStack(alignment: .leading, spacing: 12) {
        Text(screenTitle)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        Text(L10N.Common.EnterCVVCode.Screen.description)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      .padding(.top, 16)
      HStack {
        Spacer()
        PinCodeView(
          code: $viewModel.generatedCVV,
          isDisabled: $viewModel.isShowIndicator,
          codeLength: viewModel.cvvCodeDigits
        )
        Spacer()
      }
      Spacer()
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isCVVCodeEntered,
        isLoading: $viewModel.isShowIndicator
      ) {
        hideKeyboard()
        viewModel.verifyCVVCode { verifyID in
          onDissmiss?(verifyID)
        }
      }
    }
    .padding([.horizontal, .bottom], 30)
  }
}
