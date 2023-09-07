import SwiftUI
import BaseDashboard
import AccountData
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountDomain
import CodeScanner
import LFWalletAddress

struct EnterCryptoAddressView: View {
  @StateObject private var viewModel: EnterCryptoAddressViewModel
  
  private let completeAction: (() -> Void)?
  
  init(assetModel: AssetModel, completeAction: @escaping (() -> Void)) {
    _viewModel = .init(wrappedValue: EnterCryptoAddressViewModel(asset: assetModel))
    self.completeAction = completeAction
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      header
        .padding(.bottom, 8)
      VStack(alignment: .leading, spacing: 12) {
        textField
        warningLabel
      }
      if viewModel.isFetchingData {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else {
        savedWalletsAddress
      }
      Spacer()
      footer
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 20)
    .frame(maxWidth: .infinity)
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(item: $viewModel.popup) { item in
      switch item {
      case let .delete(wallet):
        deletePopup(wallet: wallet)
      }
    }
    .onTapGesture {
      hideKeyboard()
    }
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $viewModel.isShowingScanner) {
      CodeScannerView(codeTypes: [.qr], simulatedData: "") { result in
        viewModel.handleScan(result: result)
      }
    }
    .onChange(of: viewModel.inputValue) { _ in
      viewModel.filterWalletAddressList()
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .enterAmount(let address, let nickname):
        MoveCryptoInputView(
          type: .sendCrypto(address: address, nickname: nickname),
          assetModel: viewModel.asset,
          completeAction: completeAction
        )
      case .editWalletAddress(let wallet):
        EditNicknameOfWalletView(
          accountId: viewModel.asset.id,
          wallet: wallet
        )
      }
    }
  }
}

// MARK: - View Components
private extension EnterCryptoAddressView {
  var header: some View {
    ZStack(alignment: .topLeading) {
      VStack(spacing: 0) {
        titleView
      }
    }
  }
  
  @ViewBuilder var titleView: some View {
    VStack(spacing: 10) {
      Text(LFLocalizable.EnterCryptoAddressView.title(LFLocalizable.Crypto.value.uppercased()))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
    }
  }
  
  var textField: some View {
    WalletAddressTextField(
      placeHolderText: LFLocalizable.EnterCryptoAddressView.WalletAddress.placeholder,
      value: $viewModel.inputValue,
      textFieldTitle: LFLocalizable.EnterCryptoAddressView.WalletAddress
        .title(LFLocalizable.Crypto.value),
      clearValue: {
        viewModel.clearValue()
      },
      scanTap: {
        viewModel.scanAddressTap()
      }
    )
  }
  
  var warningLabel: some View {
    Text(LFLocalizable.EnterCryptoAddressView.warning(LFLocalizable.Crypto.value))
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
  }
  
  var savedWalletsAddress: some View {
    let buttons = [
      SwipeWalletCellButton(
        image: GenImages.CommonImages.icEdit.swiftUIImage,
        backgroundColor: Colors.secondaryBackground.swiftUIColor
      ) { wallet in
        viewModel.editWalletTapped(wallet: wallet)
      },
      SwipeWalletCellButton(
        image: GenImages.CommonImages.icTrash.swiftUIImage,
        backgroundColor: Colors.error.swiftUIColor
      ) { wallet in
        viewModel.deleteWalletTapped(wallet: wallet)
      }
    ]

    return ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 10) {
        ForEach(viewModel.walletsFilter, id: \.id) { wallet in
          walletNicknameCell(with: wallet)
            .swipeWalletCell(buttons: buttons, item: wallet) {
              viewModel.selectedWallet(wallet: wallet)
            }
        }
      }
    }
    .padding(.top, 12)
  }
  
  func walletNicknameCell(with wallet: APIWalletAddress) -> some View {
    HStack(spacing: 12) {
      Circle()
        .stroke(Colors.primary.swiftUIColor, lineWidth: 1)
        .frame(width: 32, height: 32)
        .overlay(
          Text((wallet.nickname ?? "").prefix(1))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
        )
      Text(wallet.nickname ?? "")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer()
      circleBoxView(isSelected: wallet.address == viewModel.walletSelected?.address)
    }
    .padding(.horizontal, 12)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
  }

  @ViewBuilder
  func circleBoxView(isSelected: Bool) -> some View {
    if isSelected {
      ZStack(alignment: .center) {
        Circle()
          .fill(Colors.primary.swiftUIColor)
          .frame(width: 20, height: 20)
        GenImages.CommonImages.icCheckmark.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
    } else {
      Circle()
        .stroke(Colors.label.swiftUIColor.opacity(0.75), lineWidth: 1)
        .frame(width: 20, height: 20)
    }
  }
  
  var error: some View {
    Text(viewModel.inlineError ?? String.empty)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.error.swiftUIColor)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .opacity(viewModel.inlineError.isNotNil ? 1 : 0)
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      continueButton
      VStack(spacing: 12) {
        cryptoDisclosure
        estimatedFeeDescription
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: !viewModel.isActionAllowed
    ) {
      viewModel.continueButtonTapped()
    }
  }
  
  @ViewBuilder var cryptoDisclosure: some View {
    Text(LFLocalizable.Zerohash.Disclosure.description)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }
  
  @ViewBuilder var estimatedFeeDescription: some View {
    Text(LFLocalizable.MoveCryptoInput.Send.estimatedFee)
      .multilineTextAlignment(.center)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }
  
  func deletePopup(wallet: APIWalletAddress) -> some View {
    LiquidityAlert(
      title: LFLocalizable.EnterCryptoAddressView.DeletePopup.title.uppercased(),
      message: LFLocalizable.EnterCryptoAddressView.DeletePopup.message(wallet.nickname ?? ""),
      primary: .init(text: LFLocalizable.EnterCryptoAddressView.DeletePopup.primaryButton) {
        viewModel.handleDelete(wallet: wallet)
      },
      secondary: .init(text: LFLocalizable.Button.Back.title) {
        viewModel.hidePopup()
      },
      isLoading: $viewModel.showIndicator
    )
  }
}
