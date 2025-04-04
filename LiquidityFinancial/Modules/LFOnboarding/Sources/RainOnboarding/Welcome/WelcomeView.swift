import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import Services
import Factory

struct WelcomeView: View {
  @StateObject var viewModel = WelcomeViewModel()
  private var destinationView: AnyView
  
  init(destinationView: AnyView) {
    self.destinationView = destinationView
  }
  
  var body: some View {
    VStack(spacing: 12) {
      staticTop
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.vertical, 12)
      mainContent
      VStack(spacing: 12) {
        continueButton
        logoutButton
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
    .background(Colors.background.swiftUIColor)
    .onAppear {
      viewModel.onAppear()
    }
    .navigationLink(isActive: $viewModel.isPushToNextStep) {
      AddressView()
      //destinationView
    }
    .navigationBarBackButtonHidden(true)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension WelcomeView {
  var staticTop: some View {
    VStack(spacing: 12) {
      GenImages.Images.welcomeHeader.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: 300, height: 232)
        .padding(.bottom, 10)
      
      Text(L10N.Common.Welcome.Header.title)
        .font(Fonts.regular.swiftUIFont(fixedSize: 24))
        .foregroundColor(Colors.label.swiftUIColor)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
      
      Text(L10N.Custom.Welcome.Header.desc)
        .font(Fonts.regular.swiftUIFont(fixedSize: 16))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
    }
    .padding(.top, 20)
  }
  
  func item(image: Image, text: String) -> some View {
    HStack(alignment: .center, spacing: 12) {
      image
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(width: 24, height: 24)
        .padding(.top, 4)
      Text(text)
        .font(Fonts.regular.swiftUIFont(fixedSize: 17))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .fixedSize(horizontal: false, vertical: true)
      Spacer()
    }
    .padding(.trailing, 12)
    .frame(maxWidth: .infinity)
  }
  
  var mainContent: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 24) {
        Text(L10N.Common.Welcome.howItWorks)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(Colors.label.swiftUIColor)
        VStack(spacing: 25) {
          item(
            image: GenImages.CommonImages.icWellcome1.swiftUIImage,
            text: L10N.Common.Welcome.HowItWorks.item1
          )
          item(
            image: GenImages.CommonImages.icWellcome2.swiftUIImage,
            text: L10N.Custom.Welcome.HowItWorks.item2
          )
          item(
            image: GenImages.CommonImages.icWellcome3.swiftUIImage,
            text: L10N.Custom.Welcome.HowItWorks.item3
          )
        }
        Spacer()
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: false,
      isLoading: .constant(false)
    ) {
      viewModel.onClickedContinueButton()
    }
  }
  
  var logoutButton: some View {
    FullSizeButton(
      title: L10N.Common.Profile.Logout.title,
      isDisable: false,
      isLoading: .constant(false),
      type: .destructive
    ) {
      viewModel.forcedLogout()
    }
  }
}
