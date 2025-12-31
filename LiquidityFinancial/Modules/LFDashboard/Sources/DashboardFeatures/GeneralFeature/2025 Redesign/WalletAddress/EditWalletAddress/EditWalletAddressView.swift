import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountData
import Services

public struct EditWalletAddressView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: EditWalletAddressViewModel
  
  @FocusState private var focusedField: FocusedField?
  
  private let callbackAction: ((String) -> Void)?
  
  public init(
    accountId: String,
    wallet: APIWalletAddress,
    callbackAction: ((String) -> Void)? = nil
  ) {
    self.callbackAction = callbackAction
    _viewModel = .init(wrappedValue: EditWalletAddressViewModel(accountId: accountId, wallet: wallet))
  }
  
  public var body: some View {
    content
      .appNavBar(navigationTitle: L10N.Common.EditWalletAddress.Screen.title)
      .onChange(
        of: viewModel.shouldDismiss,
        perform: { _ in
          dismiss()
        }
      )
      .toast(data: $viewModel.toastData)
      .navigationBarTitleDisplayMode(.inline)
      .onTapGesture {
        focusedField = nil
      }
      .track(name: String(describing: type(of: self)))
      .sheetWithContentHeight(
        isPresented: $viewModel.isShowingDeleteConfirmationSheet
      ) {
        CommonBottomSheet(
          title: L10N.Common.RemoveWalletAddress.Popup.title,
          subtitle: L10N.Common.RemoveWalletAddress.Popup.subtitle(viewModel.wallet.nickname ?? ""),
          primaryButtonTitle: L10N.Common.RemoveWalletAddress.Popup.Confirm.title,
          secondaryButtonTitle: L10N.Common.Common.Cancel.Button.title
        ) {
          viewModel.deleteWalletAddress {
            dismiss()
            callbackAction?(viewModel.wallet.nickname ?? "")
          }
        }
      }
  }
}

// MARK: View Components
extension EditWalletAddressView {
  var content: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView
      nicknameTextField
      Spacer()
      buttonsView
        .padding(.bottom, 16)
    }
    .padding(.horizontal, 24)
    .padding(.top, 4)
    .background(Colors.baseAppBackground2.swiftUIColor)
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
  
  var headerView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(L10N.Common.SaveWalletAddress.Header.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
      
      Text(viewModel.wallet.address)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.textSecondary.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
  }
  
  var buttonsView: some View {
    VStack(spacing: 12) {
      FullWidthButton(
        title: L10N.Common.Common.Save.Button.title,
        isDisabled: !viewModel.isActionAllowed || viewModel.showSaveIndicator || viewModel.showDeleteIndicator,
        isLoading: $viewModel.showSaveIndicator
      ) {
        hideKeyboard()
        viewModel.editWalletAddress()
      }
      
      FullWidthButton(
        backgroundColor: Colors.grey400.swiftUIColor,
        title: L10N.Common.EditWalletAddress.Delete.Button.title,
        isDisabled: viewModel.showSaveIndicator || viewModel.showDeleteIndicator,
        isLoading: $viewModel.showDeleteIndicator
      ) {
        hideKeyboard()
        viewModel.isShowingDeleteConfirmationSheet = true
      }
    }
  }
}

// MARK: - Private Enums
extension EditWalletAddressView {
  enum FocusedField {
    case walletNickname
  }
}
