import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

public struct SetCardPinView<ViewModel: SetCardPinViewModelProtocol>: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject
  private var viewModel: ViewModel
    
  public init(viewModel: ViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
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
private extension SetCardPinView {
  var content: some View {
    VStack(alignment: .leading, spacing: 50) {
      Text(LFLocalizable.SetCardPin.Screen.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.top, 16)
      VStack(spacing: 20) {
        pinView
        Text(LFLocalizable.SetCardPin.Screen.description)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
          .padding(.horizontal, 20)
          .lineSpacing(1.7)
      }
      .padding(.horizontal, 16)
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !viewModel.isPinEntered,
        isLoading: $viewModel.isShowIndicator
      ) {
        hideKeyboard()
        viewModel.setCardPIN()
      }
    }
    .padding([.horizontal, .bottom], 30)
  }
  
  var pinView: some View {
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
        .background(item.text.isEmpty ? Colors.secondaryBackground.swiftUIColor : Colors.buttons.swiftUIColor)
        .cornerRadius(10)
        .frame(width: 58, height: 70)
      }
    }
    .onChange(of: viewModel.generatedPin) { pinCode in
      viewModel.onReceivedPinCode(pinCode: pinCode)
    }
  }
  
  var successPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.SetCardPin.Popup.title,
      message: LFLocalizable.SetCardPin.Popup.successMessage,
      primary: .init(text: LFLocalizable.Button.Ok.title) {
        viewModel.handleSuccessPrimaryAction {
          hideKeyboard()
          dismiss()
        }
      },
      secondary: nil
    )
  }
}
