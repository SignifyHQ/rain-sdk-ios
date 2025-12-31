import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

public struct SaveWalletAddressView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: SaveWalletAddressViewModel
  
  let popAction: (() -> Void)?
  
  public init(
    accountId: String,
    walletAddress: String,
    popAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(wrappedValue: SaveWalletAddressViewModel(accountId: accountId, walletAddress: walletAddress))
    self.popAction = popAction
  }

  public var body: some View {
    content
      .appNavBar(navigationTitle: L10N.Common.SaveWalletAddress.Screen.title)
      .onChange(
        of: viewModel.shouldDismiss,
        perform: { _ in
          if let popAction = popAction {
            popAction()
          } else {
            LFUtilities.popToRootView()
          }
        }
      )
      .toast(data: $viewModel.toastData)
      .navigationBarTitleDisplayMode(.inline)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
extension SaveWalletAddressView {
  var content: some View {
    VStack(alignment: .leading, spacing: 32) {
      headerView
      
      nicknameTextField
      
      Spacer()
      
      FullWidthButton(
        title: L10N.Common.Common.Save.Button.title,
        isDisabled: !viewModel.isActionAllowed,
        isLoading: $viewModel.showIndicator
      ) {
        hideKeyboard()
        viewModel.onSaveButtonTap()
      }
      .padding(.bottom, 16)
    }
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
  }
  
  var nicknameTextField: some View {
    WalletAddressNicknameTextField(nickname: $viewModel.walletNickname)
  }

  var headerView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(L10N.Common.SaveWalletAddress.Header.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
      
      Text(viewModel.walletAddress)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.textSecondary.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
  }
}
