import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import Factory

struct CreateWalletView: View {
  @StateObject var viewModel = CreateWalletViewModel()
  
  var body: some View {
    content
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .defaultToolBar(icon: .support) {
        viewModel.openSupportScreen()
      }
      .navigationLink(isActive: $viewModel.isNavigateToBackupWalletView) {
        BackupWalletView()
      }
      .navigationBarBackButtonHidden(viewModel.showIndicator)
      .track(name: String(describing: type(of: self)))
      .onAppear {
        viewModel.onAppear()
      }
      .fullScreenCover(item: $viewModel.openSafariType) { type in
        switch type {
        case .portalURL(let uRL):
          SFSafariViewWrapper(url: uRL)
        case .disclosureURL(let uRL):
          SFSafariViewWrapper(url: uRL)
        case .walletPrivacyURL(let uRL):
          SFSafariViewWrapper(url: uRL)
        }
      }
  }
}

// MARK: - View Components
private extension CreateWalletView {
  var content: some View {
    VStack(alignment: .leading, spacing: 24) {
      headerTitle
      logoWithPartnerView
      Spacer()
      termsView
      continueButton
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
  }
  
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.CreateWallet.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(L10N.Common.CreateWallet.info(LFUtilities.appName))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
    .padding(.top, 6)
    .padding(.bottom, 30)
  }
  
  var logoWithPartnerView: some View {
    HStack {
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(80)
        .onTapGesture(count: 5) {
          NotificationCenter.default.post(name: .forceLogoutInAnyWhere, object: nil)
        }
      Spacer()
      GenImages.CommonImages.portal.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: 173, height: 36)
    }
    .padding(16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  @ViewBuilder
  var checkBoxImage: some View {
    if viewModel.isTermsAgreed {
      GenImages.Images.termsCheckboxSelected.swiftUIImage
    } else {
      GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
        .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
    }
  }
  
  var termsView: some View {
    HStack {
      checkBoxImage
        .onTapGesture {
          viewModel.isTermsAgreed.toggle()
        }
        .padding(.bottom, 130)
      TextTappable(
        text: viewModel.strMessage,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [
          viewModel.strUserAgreement,
          viewModel.strPrivacy,
          viewModel.strDiscloures
        ],
        style: .underlined(Colors.cryptoTermsUnderline.color)
      ) { tappedString in
        viewModel.onClickedTermLink(link: tappedString)
      }
      .frame(height: 170)
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: !viewModel.isTermsAgreed,
      isLoading: $viewModel.showIndicator
    ) {
      viewModel.onCreatePortalWalletTapped()
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 12)
  }
}
