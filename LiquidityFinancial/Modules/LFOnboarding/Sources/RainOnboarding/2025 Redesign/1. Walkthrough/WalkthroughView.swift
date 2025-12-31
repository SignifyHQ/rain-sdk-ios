import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct WalkthroughView: View {
  @StateObject var viewModel: WalkthroughViewModel
  
  public init(
    viewModel: WalkthroughViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack() {
      contentView
      
      Spacer()
      
      buttonGroup
    }
    .padding(.top, 4)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      }
    )
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        switch navigation {
        case .countryOfResidence(let type):
          CountryOfResidenceView(
            viewModel: CountryOfResidenceViewModel(
              authMethod: type == .phone ? .phone : .email
            )
          )
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension WalkthroughView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 32
    ) {
      headerView
      
      VStack(
        spacing: -80
      ) {
        stepImage(index: 1, image: GenImages.Images.imgOnboardingStep1.swiftUIImage)
        stepImage(index: 2, image: GenImages.Images.imgOnboardingStep2.swiftUIImage)
        stepImage(index: 3, image: GenImages.Images.imgOnboardingStep3.swiftUIImage)
      }
    }
  }
  
  var headerView: some View {
    Text(L10N.Common.Walkthrough.Header.title)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      if viewModel.step < 3 {
        FullWidthButton(
          type: .primary,
          icon: GenImages.Images.icoArrowButtonNext.swiftUIImage,
          iconPlacement: .trailing(spacing: 4),
          title: L10N.Common.Common.Next.Button.title
        ) {
          viewModel.onNextButtonTap()
        }
      } else {
        FullWidthButton(
          type: .primary,
          icon: GenImages.Images.icoPhone.swiftUIImage,
          title: L10N.Common.Walkthrough.Signup.Phone.Button.title
        ) {
          viewModel.onSignUpButtonTap(with: .phone)
        }
        
        FullWidthButton(
          type: .alternativeBordered,
          icon: GenImages.Images.icoMail.swiftUIImage,
          title: L10N.Common.Walkthrough.Signup.Email.Button.title
        ) {
          viewModel.onSignUpButtonTap(with: .email)
        }
      }
    }
    .animation(
      .easeOut(
        duration: 0.5
      ),
      value: viewModel.step
    )
  }
}

// MARK: - Helper Methods
private extension WalkthroughView {
  @ViewBuilder
  private func stepImage(
    index: Int, image: Image
  ) -> some View {
    image
      .opacity(viewModel.step >= index ? 1 : 0)
      .offset(
        y: viewModel.step >= index ? 0 : 20
      )
      .animation(
        .easeOut(
          duration: 0.4
        ),
        value: viewModel.step
      )
  }
}
