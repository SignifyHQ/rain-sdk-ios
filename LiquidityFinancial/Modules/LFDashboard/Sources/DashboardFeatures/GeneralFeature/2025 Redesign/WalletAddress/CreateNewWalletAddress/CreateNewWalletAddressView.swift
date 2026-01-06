import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

public struct CreateNewWalletAddressView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: CreateNewWalletAddressViewModel
  
  @FocusState private var focusedField: FocusedField?
  
  private let callbackAction: ((String) -> Void)?
  
  public init(
    accountId: String,
    callbackAction: ((String) -> Void)? = nil
  ) {
    _viewModel = .init(wrappedValue: CreateNewWalletAddressViewModel(accountId: accountId))
    self.callbackAction = callbackAction
  }

  public var body: some View {
    content
      .padding(.horizontal, 24)
      .padding(.top, 8)
      .background(Colors.baseAppBackground2.swiftUIColor)
      .appNavBar(navigationTitle: L10N.Common.SaveNewWalletAddress.Screen.title)
      .toast(data: $viewModel.toastData)
      .frame(maxWidth: .infinity)
      .navigationBarTitleDisplayMode(.inline)
      .onTapGesture {
        focusedField = nil
      }
      .track(name: String(describing: type(of: self)))
      .fullScreenCover(isPresented: $viewModel.isShowingScanner) {
        QRScannerView { result in
          viewModel.handleScan(result: result)
        }
      }
  }
}

// MARK: View Components
extension CreateNewWalletAddressView {
  var content: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      walletAddressTextField
      
      nicknameTextField
      
      Spacer()
      
      FullWidthButton(
        title: L10N.Common.SaveNewWalletAddress.Screen.title,
        isDisabled: !viewModel.isActionAllowed,
        isLoading: $viewModel.showIndicator
      ) {
        hideKeyboard()
        viewModel.onContinueButtonTap {
          dismiss()
          callbackAction?(viewModel.walletNickname)
        }
      }
      .padding(.bottom, 16)
    }
  }
  
  var walletAddressTextField: some View {
    WalletAddressInputView(
      walletAddress: $viewModel.walletAddress,
      onScanButtonTap: {
        viewModel.onScanButtonTap()
      }
    )
    .focused(
      $focusedField,
      equals: .walletAddress
    )
  }
  
  var nicknameTextField: some View {
    WalletAddressNicknameTextField(
      nickname: $viewModel.walletNickname
    )
    .focused(
      $focusedField,
      equals: .walletNickname
    )
  }
}

// MARK: - Private Enums
extension CreateNewWalletAddressView {
  enum FocusedField {
    case walletAddress
    case walletNickname
  }
}
