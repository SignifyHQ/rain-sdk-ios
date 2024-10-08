import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import Factory
import BaseOnboarding

struct CreateWalletView: View {
  @StateObject var viewModel = CreateWalletViewModel()
  @Injected(\.contentViewFactory) var contentViewFactory

  var body: some View {
    content
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .popup(item: $viewModel.popup) { popup in
        switch popup {
        case .settingICloud:
          settingICloudPopup
        }
      }
      .defaultToolBar(icon: .support, openSupportScreen: {
        viewModel.openSupportScreen()
      })
      .navigationLink(isActive: $viewModel.isNavigateToPersonalInformation) {
        let enterSSNView = EnterSSNView(
          viewModel: EnterSSNViewModel(),
          onEnterAddress: {
            contentViewFactory.baseOnboardingNavigation.enterSSNDestinationView = .address(
              AnyView(AddressView())
            )
          }
        )
        
        PersonalInformationView(
          viewModel: PersonalInformationViewModel(),
          onEnterSSN: {
            contentViewFactory.baseOnboardingNavigation.personalInformationDestinationView = .enterSSN(
              AnyView(enterSSNView)
            )
          }
        )
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
        .frame(width: 158, height: 40)
        .padding(.trailing, 16)
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
        .padding(.bottom, 24)
      TextTappable(
        text: viewModel.strMessage,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [
          viewModel.strUserAgreement,
          viewModel.strPrivacy,
          viewModel.strDiscloures
        ]
      ) { tappedString in
        viewModel.onClickedTermLink(link: tappedString)
      }
      .frame(height: 80)
      .padding(.bottom, -20)
    }
  }
  
  var continueButton: some View {
    VStack(spacing: 4) {
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isTermsAgreed,
        isLoading: $viewModel.showIndicator
      ) {
        viewModel.onCreatePortalWalletTapped()
      }
      Text(viewModel.loadingText)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 12)
  }
  
  var settingICloudPopup: some View {
    LiquidityAlert(
      title: L10N.Common.CreateWallet.SignInToIcloud.title,
      message: L10N.Common.CreateWallet.SignInToIcloud.message,
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.hidePopup()
        viewModel.openDeviceSettings()
      },
      secondary: .init(text: L10N.Common.Button.NotNow.title) {
        viewModel.hidePopup()
      }
    )
  }
}
