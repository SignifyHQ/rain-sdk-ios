import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI
import AVKit
import AVFoundation

public struct LandingView: View {
  @StateObject var viewModel: LandingViewModel
  
  public init(
    viewModel: LandingViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack {
      GenImages.Images.imgLogoOnboardingLanding.swiftUIImage
        .padding(.top, 72)
        .onTapGesture(
          count: 5,
          simultaneous: true
        ) {
          viewModel.onSwitchEnvironmentButtonTap()
        }
      
      Spacer()
      
      LocalVideoView(fileName: "intro_video")
        .frame(maxWidth: .infinity)
        .aspectRatio(374/205, contentMode: .fit)
      
      Spacer()
      
      buttonGroup
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
    }
    .background(.black)
    .toast(
      data: $viewModel.currentToast
    )
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        switch navigation {
        case .walkthrough:
          WalkthroughView(
            viewModel: WalkthroughViewModel()
          )
        case .authentication(let type):
          PhoneEmailAuthView(
            viewModel: PhoneEmailAuthViewModel(
              authType: .login(type == .email ? .email : .phone)
            )
          )
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension LandingView {
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .secondary,
        backgroundColor: Colors.buttonSurfaceSecondary.swiftUIColor,
        borderColor: Colors.greyDefault.swiftUIColor,
        icon: GenImages.Images.icoPhone.swiftUIImage,
        title: L10N.Common.Landing.Login.Phone.Button.title
      ) {
        viewModel.onLoginButtonTap(with: .phone)
      }
      
      FullWidthButton(
        type: .secondary,
        backgroundColor: Colors.buttonSurfaceSecondary.swiftUIColor,
        borderColor: Colors.greyDefault.swiftUIColor,
        icon: GenImages.Images.icoMail.swiftUIImage,
        title: L10N.Common.Landing.Login.Email.Button.title
      ) {
        viewModel.onLoginButtonTap(with: .email)
      }
      
      signupGroup
    }
  }
  
  var signupGroup: some View {
    VStack(
      spacing: 4
    ) {
      Text(L10N.Custom.Landing.Signup.Description.title)
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      
      FullWidthButton(
        type: .secondary,
        backgroundColor: Colors.buttonSurfaceSecondary.swiftUIColor,
        borderColor: Colors.greyDefault.swiftUIColor,
        title: L10N.Common.Landing.Signup.Button.title
      ) {
        viewModel.onSignupButtonTap()
      }
    }
  }
}
