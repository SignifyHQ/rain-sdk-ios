import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

public struct EnterNicknameOfWalletView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: EnterNicknameOfWalletViewModel
  let popAction: (() -> Void)?
  
  public init(
    accountId: String,
    walletAddress: String,
    popAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(wrappedValue: EnterNicknameOfWalletViewModel(accountId: accountId, walletAddress: walletAddress))
    self.popAction = popAction
  }

  public var body: some View {
    content
      .onChange(of: viewModel.walletNickname) { _ in
        viewModel.onEditingWalletName()
      }
      .onChange(of: viewModel.shouldDismiss, perform: { _ in
        popAction?()
      })
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .adaptToKeyboard()
      .ignoresSafeArea(edges: .bottom)
      .navigationBarTitleDisplayMode(.inline)
      .track(name: String(describing: type(of: self)))
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
        title: L10N.Common.EnterNicknameOfWallet.saveButton,
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
      Text(L10N.Common.EnterNicknameOfWallet.textFieldTitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      TextFieldWrapper {
        TextField("", text: $viewModel.walletNickname)
          .keyboardType(.alphabet)
          .modifier(PlaceholderStyle(showPlaceHolder: $viewModel.walletNickname.wrappedValue.isEmpty, placeholder: L10N.Common.EnterNicknameOfWallet.placeholder))
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
        Text(L10N.Common.EnterNicknameOfWallet.disclosures)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.5)
      }
    }
  }

  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10N.Common.EnterNicknameOfWallet.saveTitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(L10N.Common.EnterNicknameOfWallet.createNickname(viewModel.walletAddress))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.leading)
    }
    .padding(.top, 12)
  }
}
