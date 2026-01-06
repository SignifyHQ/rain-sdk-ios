import SwiftUI
import AccountData
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountDomain
import Services
import GeneralFeature

struct WalletAddressEntryView: View {
  @StateObject private var viewModel: WalletAddressEntryViewModel
  
  private let completeAction: (() -> Void)?
  
  init(
    viewModel: WalletAddressEntryViewModel,
    completeAction: @escaping (() -> Void)
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.completeAction = completeAction
  }
  
  var body: some View {
    VStack {
      ScrollView(showsIndicators: false) {
        VStack(
          alignment: .leading,
          spacing: 24
        ) {
          headerView
          textFieldView
          
          if viewModel.isFetchingData {
            VStack(
              alignment: .center
            ) {
              DefaultLottieView(
                loading: .ctaFast
              )
              .frame(
                width: 30,
                height: 20
              )
            }
            .frame(
              maxWidth: .infinity
            )
          } else {
            savedWalletsAddress
          }
        }
        .padding(.top, 8)
      }
      Spacer()
      footerView
    }
    .appNavBar(
      navigationTitle: viewModel.kind.getTitle(asset: viewModel.asset.type?.symbol ?? .empty)
    )
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .toast(data: $viewModel.toastData)
    .onTapGesture {
      hideKeyboard()
    }
    .navigationBarTitleDisplayMode(.inline)
    .fullScreenCover(isPresented: $viewModel.isShowingScanner) {
      QRScannerView { result in
        viewModel.handleScan(result: result)
      }
    }
    .sheetWithContentHeight(
      item: $viewModel.popup,
      content: { popup in
        switch popup {
        case .openSettings:
          openSettingsPopup
        case .showLearnMore:
          LearnMoreView()
        }
      }
    )
    .onChange(of: viewModel.inputValue) { _, _ in
      viewModel.filterWalletAddressList()
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .enterAmount:
        WithdrawalAmountEntryView(
          assetModel: viewModel.asset,
          address: viewModel.inputValue,
          nickname: viewModel.selectedNickname,
          completeAction: completeAction
        )
      case .editWalletAddress(let wallet):
        EditWalletAddressView(
          accountId: viewModel.asset.id,
          wallet: wallet
        ) { nickname in
          viewModel.showDeletedWalletToast(nickname: nickname)
        }
      }
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension WalletAddressEntryView {
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text(L10N.Common.WalletAddressInput.Header.title)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
      
      HStack(alignment: .top, spacing: 4 ) {
        GenImages.Images.icoWarning.swiftUIImage
          .resizable()
          .frame(width: 20, height: 20)
        
        TextTappable(
          text: L10N.Common.WalletAddressInput.Header.subtitle,
          textAlignment: .natural,
          verticalTextAlignment: .top,
          textColor: Colors.textSecondary.color,
          fontSize: Constants.FontSize.small.value,
          links: [
            L10N.Common.WalletAddressInput.Header.learnMoreLink
          ],
          style: .underlined(Colors.blue300.color),
          weight: .regular
        ) { _ in
          viewModel.popup = .showLearnMore
        }
      }
    }
  }
  
  var textFieldView: some View {
    WalletAddressInputView(
      walletAddress: $viewModel.inputValue,
      onScanButtonTap: {
        viewModel.onScanButtonTap()
      }
    )
  }
  
  var savedWalletsAddress: some View {
    return ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 10) {
        ForEach(viewModel.walletsFilter, id: \.id) { wallet in
          walletNicknameCell(with: wallet)
            .onTapGesture {
              viewModel.onWalletSelect(wallet: wallet)
            }
        }
      }
    }
  }
  
  func walletNicknameCell(with wallet: APIWalletAddress) -> some View {
    HStack(spacing: 12) {
      circleBoxView(isSelected: wallet.address == viewModel.walletSelected?.address)
      
      Text(wallet.nickname ?? "")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer()
      
      Button {
        viewModel.onEditWalletTap(wallet: wallet)
      } label: {
        GenImages.Images.icoEdit.swiftUIImage
          .resizable()
          .frame(width: 24, height: 24)
      }
    }
    .padding(.leading, 24)
    .padding(.trailing, 12)
    .frame(height: 48)
    .cornerRadius(24)
    .overlay {
      RoundedRectangle(cornerRadius: 24)
        .strokeBorder(Colors.grey300.swiftUIColor, lineWidth: 1)
    }
  }

  @ViewBuilder
  func circleBoxView(isSelected: Bool) -> some View {
    if isSelected {
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .frame(width: 20, height: 20, alignment: .center)
        .foregroundColor(Colors.success500.swiftUIColor)
    } else {
      Circle()
        .stroke(Colors.iconPrimary.swiftUIColor, lineWidth: 2)
        .frame(width: 20, height: 20)
    }
  }
  
  var errorView: some View {
    Text(viewModel.inlineError ?? String.empty)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.error.swiftUIColor)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .opacity(viewModel.inlineError.isNotNil ? 1 : 0)
  }
  
  var footerView: some View {
    VStack(spacing: 8) {
      continueButton
      estimatedFeeNoteView
    }
    .padding(.bottom, 16)
  }
  
  var continueButton: some View {
    FullWidthButton(
      type: .primary,
      title: L10N.Common.Button.Continue.title,
      isDisabled: !viewModel.isActionAllowed
    ) {
      viewModel.onContinueButtonTap()
    }
  }
  
  var estimatedFeeNoteView: some View {
    Text(L10N.Common.WalletAddressInput.note)
      .foregroundColor(Colors.textSecondary.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .multilineTextAlignment(.center)
  }
  
  var openSettingsPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.NotificationSetting.Popup.title,
      subtitle: L10N.Common.NotificationSetting.Popup.subtitle,
      primaryButtonTitle: L10N.Common.Common.Open.Button.title,
      secondaryButtonTitle: L10N.Common.Common.Close.Button.title,
      primaryAction: {
        viewModel.popup = nil
        viewModel.openSettings()
      }
    )
  }
}
