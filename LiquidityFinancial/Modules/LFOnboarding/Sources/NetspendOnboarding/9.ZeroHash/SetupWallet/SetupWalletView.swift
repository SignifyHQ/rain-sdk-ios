import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import Factory

struct SetupWalletView: View {
  @Injected(\.analyticsService)
  var analyticsService
  @Environment(\.openURL)
  var openURL
  @StateObject
  var viewModel = SetupWalletViewModel()

  var body: some View {
    GeometryReader { geo in
      Colors.background.swiftUIColor.edgesIgnoringSafeArea(.all)
      VStack {
        HStack {
          Spacer()
          Button {
            viewModel.openSupportScreen()
          } label: {
            GenImages.CommonImages.icChat.swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
              .frame(width: 50, height: 50)
          }
        }
        .padding(.horizontal, 20)
        .frame(width: geo.size.width, alignment: .trailing)
        
        VStack {
          VStack {
            Text(LFLocalizable.SetUpWallet.title)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
              .padding(.horizontal, 35)
              .frame(width: geo.size.width, alignment: .leading)
              .padding(.bottom, 20)
              .padding(.top, 15)
            Text(LFLocalizable.SetUpWallet.info(LFUtilities.appName))
              .foregroundColor(Colors.label.swiftUIColor)
              .opacity(0.75)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
              .padding(.horizontal, 35)
              .frame(width: geo.size.width, alignment: .leading)
              .padding(.bottom, 25)
            HStack {
              GenImages.Images.icLogo.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(80)
                .gesture(tap)
              Spacer()
              GenImages.CommonImages.zerohash.swiftUIImage
            }
            .padding(16)
            .background(Colors.secondaryBackground.swiftUIColor)
            .cornerRadius(10)
            .shadow(radius: 10.0)
            .padding(.horizontal, 30)
          }
          Spacer()
          terms
          bottom
        }
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .navigationLink(isActive: $viewModel.isNavigateToRewardsView) {
        RewardTermsView()
      }
    }
    .navigationBarHidden(true)
    .navigationBarBackButtonHidden(viewModel.showIndicator)
    .track(name: String(describing: type(of: self)))
    .onAppear {
      analyticsService.track(event: AnalyticsEvent(name: .viewsWalletSetup))
    }
  }

  private var tap: some Gesture {
    TapGesture(count: 5)
      .onEnded {
        NotificationCenter.default.post(name: .forceLogoutInAnyWhere, object: nil)
      }
  }
}

extension SetupWalletView {
  
  private var terms: some View {
    HStack {
      Group {
        if viewModel.isTermsAgreed {
          GenImages.Images.termsCheckboxSelected.swiftUIImage
            .onTapGesture {
              viewModel.isTermsAgreed.toggle()
            }
        } else {
          GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
            .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
            .onTapGesture {
              viewModel.isTermsAgreed.toggle()
            }
        }
      }
      .padding(.leading, 20)
      .padding(.bottom, 130)
      let strMessage = LFLocalizable.SetUpWallet.termsAndCondition
      let strUserAgreement = LFLocalizable.SetUpWallet.userAgreement
      let strPrivacy = LFLocalizable.SetUpWallet.solidPrivacyPolicy
      let strDiscloures = LFLocalizable.SetUpWallet.regulatoryDisclosures

      TextTappable(
        text: strMessage,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [strUserAgreement, strPrivacy, strDiscloures],
        style: .underlined(Colors.cryptoTermsUnderline.color)
      ) { tappedString in
        if tappedString == strUserAgreement {
          if let url = URL(string: LFUtilities.zerohashURL) {
            openURL(url)
          }
        } else if tappedString == strDiscloures {
          if let url = URL(string: LFUtilities.disclosureURL) {
            openURL(url)
          }
        } else {
          if let url = URL(string: LFUtilities.walletPrivacyURL) {
            openURL(url)
          }
        }
      }
      .frame(height: 170)
      .padding(.trailing, 50)
      .padding(.leading, 5)
    }
  }
  
  private var bottom: some View {
    VStack {
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !viewModel.isTermsAgreed,
        isLoading: $viewModel.showIndicator
      ) {
        viewModel.createZeroHashAccount()
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 12)
    .padding(.horizontal, 32)
  }
}

// MARK: - SetupWalletView_Previews

struct SetupWalletView_Previews: PreviewProvider {
  static var previews: some View {
    SetupWalletView()
      .embedInNavigation()
  }
}
