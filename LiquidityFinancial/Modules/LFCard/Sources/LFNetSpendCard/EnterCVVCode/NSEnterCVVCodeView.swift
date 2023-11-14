import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

public struct NSEnterCVVCodeView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: NSEnterCVVCodeViewModel
  let screenTitle: String
  let onDissmiss: ((String) -> Void)?
  
  public init(viewModel: NSEnterCVVCodeViewModel, screenTitle: String, onDissmiss: @escaping (String) -> Void) {
    _viewModel = .init(wrappedValue: viewModel)
    self.screenTitle = screenTitle
    self.onDissmiss = onDissmiss
  }
  
  public var body: some View {
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
        Text(LFLocalizable.EnterCVVCode.Screen.description)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      .padding(.top, 16)
      HStack {
        Spacer()
        cvvCodeView
        Spacer()
      }
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
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
  
  var cvvCodeView: some View {
    HStack(spacing: 10) {
      ForEach(viewModel.pinViewItems) { item in
        PinTextField(
          viewItem: item,
          isShown: viewModel.isShown,
          onTextChange: { value in
            viewModel.textFieldTextChange(replacementText: value, viewItem: item)
          },
          onBackPressed: { item in
            viewModel.onTextFieldBackPressed(viewItem: item)
          }
        )
        .background(item.text.isEmpty ? Colors.buttons.swiftUIColor : Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(10)
        .frame(width: 58, height: 70)
      }
    }
    .onChange(of: viewModel.generatedCVV) { cvvCode in
      viewModel.onReceivedCVVCode(cvvCode: cvvCode)
    }
  }
}
