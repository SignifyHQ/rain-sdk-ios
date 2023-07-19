import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct SetupWalletView: View {
  @Environment(\.openURL) var openURL
  @StateObject private var viewModel = SetupWalletViewModel()

  var body: some View {
    LoadingIndicatorView(isShowing: $viewModel.showIndicator) {
      GeometryReader { gr in
        Colors.background.swiftUIColor.edgesIgnoringSafeArea(.all)
        VStack {
          HStack {
            Spacer()

            Button {
              //intercomService.openIntercom()
            } label: {
              GenImages.CommonImages.icChat.swiftUIImage
                .foregroundColor(Colors.label.swiftUIColor)
                .frame(width: 50, height: 50)
            }
          }
          .padding(.horizontal, 20)
          .frame(width: gr.size.width, alignment: .trailing)

          VStack {
            VStack {
              Text(LFLocalizable.SetUpWallet.title)
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
                .padding(.horizontal, 35)
                .frame(width: gr.size.width, alignment: .leading)
                .padding(.bottom, 20)
                .padding(.top, 15)

              Text(LFLocalizable.SetUpWallet.info)
                .foregroundColor(Colors.label.swiftUIColor)
                .opacity(0.75)
                .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
                .padding(.horizontal, 35)
                .frame(width: gr.size.width, alignment: .leading)
                .padding(.bottom, 25)

              HStack {
                GenImages.Images.icLogo.swiftUIImage
                  .resizable()
                  .scaledToFill()
                  .padding(.leading, 45)
                  .frame(width: 80.0, height: 80.0)
                  .gesture(tap)
                Spacer()

                GenImages.CommonImages.zerohash.swiftUIImage
                  .foregroundColor(Colors.green.swiftUIColor)
                  .padding(.trailing, 45)
              }
              .frame(
                width: abs(gr.size.width - 60),
                height: 130,
                alignment: .center
              )
              .background(Colors.secondaryBackground.swiftUIColor)
              .cornerRadius(10)
              .shadow(radius: 10.0)
            }

            Spacer()

            terms

            bottom
          }
        }
        .popup(item: $viewModel.toastMessage, style: .toast) {
          ToastView(toastMessage: $0)
        }
        .onAppear {
          //analyticsService.track(event: Event(name: .viewsWalletSetup))
        }
      }
      .navigationBarHidden(true)
    }
  }

  private var tap: some Gesture {
    TapGesture(count: 5)
      .onEnded {
        // TODO: Log out
        // userManager.logout()
      }
  }
}

extension SetupWalletView {
  
  private var terms: some View {
    HStack {
      Button {
        viewModel.isTermsAgreed.toggle()
      } label: {
        let image = viewModel.isTermsAgreed ?
        GenImages.CommonImages.termsCheckboxSelected.swiftUIImage :
        GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
        
        image.foregroundColor(Colors.primary.swiftUIColor)
      }
      .padding(.leading, 20)
      .padding(.bottom, 130)
      
      let strMessage = LFLocalizable.SetUpWallet.termsAndCondition
      let strUserAgreement = LFLocalizable.SetUpWallet.userAgreement
      let strPrivacy = LFLocalizable.SetUpWallet.solidPrivacyPolicy
      let strDiscloures = LFLocalizable.SetUpWallet.regulatoryDisclosures

      TextTappable(
        text: strMessage,
        links: [strUserAgreement, strPrivacy, strDiscloures],
        style: .underlined
      ) { tappedString in
        if tappedString == strUserAgreement {
          if let url = URL(string: LFUtility.zerohashURL) {
            openURL(url)
          }
        } else if tappedString == strDiscloures {
          if let url = URL(string: LFUtility.disclosureURL) {
            openURL(url)
          }
        } else {
          if let url = URL(string: LFUtility.walletPrivacyURL) {
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
        isDisable: !viewModel.isTermsAgreed
      ) {
        // CreateCryptoAccount()
      }

      Text(LFLocalizable.zeroHashTransactiondetail)
        .font(Fonts.Inter.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.50))
        .padding(.horizontal, 10)
        .padding(.top, 10)

    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 5)
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
