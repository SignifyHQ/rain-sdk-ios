import BaseOnboarding
import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct KycView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: KycViewModel
  
  public init(
    viewModel: KycViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(
      spacing: 32
    ) {
      progressView
      
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
      },
      isBackButtonHidden: true
    )
    .disabled(viewModel.isLoading)
    .fullScreenCover(
      item: $viewModel.webViewNavigation
    ) { item in
      switch item {
      case let .kyc(url):
        IdentityVerificationView(url: url) {
          viewModel.onWebViewCompleted()
        } closeCallback: {
          viewModel.onWebViewCompleted()
        }
      }
    }
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        onboardingViewFactory.createView(for: navigation)
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension KycView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView
      
      poweredByView
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var progressView: some View {
    SegmentedProgressBar(
      totalSteps: 8,
      currentStep: .constant(8)
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text("You’re almost there! Help us verify\nyour identity")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Text("Please have a valid Driver’s License, Government\nID or Passport handy for this.")
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var poweredByView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      HStack(
        spacing: 3
      ) {
        Text("Powered by")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundStyle(Colors.titleSecondary.swiftUIColor)
        
        GenImages.Images.icoSumsub.swiftUIImage
        
        Spacer()
      }
    }
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: "Continue",
        isDisabled: !viewModel.isContinueButtonEnabled,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.onContinueButtonTap()
      }
    }
  }
}

// MARK: - Private Enums
extension KycView {}
