import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

// MARK: - EnterNicknameOfWalletView

struct EnterNicknameOfWalletView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: EnterNicknameOfWalletViewModel
  
  init(accountId: String, walletAddress: String) {
    _viewModel = .init(wrappedValue: EnterNicknameOfWalletViewModel(accountId: accountId, walletAddress: walletAddress))
  }

  var body: some View {
    content
      .onChange(of: viewModel.walletNickname) { _ in
        viewModel.onEditingWalletName()
      }
      .onChange(of: viewModel.shouldDismiss, perform: { _ in
        dismiss()
      })
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .adaptToKeyboard()
      .ignoresSafeArea(edges: .bottom)
      .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: View Components

private extension EnterNicknameOfWalletView {
  var content: some View {
    VStack(alignment: .leading, spacing: 32) {
      headerTitle
      nicknameTextField
      Spacer()
      FullSizeButton(
        title: LFLocalizable.EnterNicknameOfWallet.saveButton,
        isDisable: !viewModel.isActionAllowed,
        isLoading: $viewModel.showIndicator
      ) {
        viewModel.saveWalletAddress()
      }
    }
    .padding(30)
    .background(Colors.background.swiftUIColor)
  }
  
  var nicknameTextField: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.EnterNicknameOfWallet.textFieldTitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      TextFieldWrapper {
        TextField("", text: $viewModel.walletNickname)
          .keyboardType(.alphabet)
          .modifier(PlaceholderStyle(showPlaceHolder: $viewModel.walletNickname.wrappedValue.isEmpty, placeholder: LFLocalizable.EnterNicknameOfWallet.placeholder))
          .primaryFieldStyle()
          .autocorrectionDisabled()
          .limitInputLength(value: $viewModel.walletNickname, length: Constants.MaxCharacterLimit.nameLimit.value)
          .submitLabel(.done)
      }
      
      if let inlineMessage = viewModel.inlineMessage {
        Text(inlineMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.error.swiftUIColor)
          .shakeAnimation(with: viewModel.numberOfShakes)
      } else {
        Text(LFLocalizable.EnterNicknameOfWallet.disclosures)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.5)
      }
    }
  }

  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(LFLocalizable.EnterNicknameOfWallet.saveTitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(LFLocalizable.EnterNicknameOfWallet.createNickname(viewModel.walletAddress))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.leading)
    }
    .padding(.top, 12)
  }
}
