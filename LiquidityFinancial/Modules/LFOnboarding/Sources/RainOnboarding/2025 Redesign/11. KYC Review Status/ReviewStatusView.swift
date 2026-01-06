import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct ReviewStatusView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: ReviewStatusViewModel
  
  public init(
    viewModel: ReviewStatusViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(
      spacing: 32
    ) {
      Spacer()
      
      contentView
      
      Spacer()
      
      buttonGroup
    }
    .padding(.top, 8)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundPrimary.swiftUIColor)
    .navigationBarBackButtonHidden()
    .toast(
      data: $viewModel.currentToast
    )
    .disabled(viewModel.isLoading)
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
private extension ReviewStatusView {
  var contentView: some View {
    VStack(
      alignment: .center,
      spacing: 32
    ) {
      GenImages.Images.imgLogoSplash.swiftUIImage
        .resizable()
        .frame(
          width: 195,
          height: 35
        )
      
      reviewStatusView
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var reviewStatusView: some View {
    VStack(
      alignment: .center,
      spacing: 4
    ) {
      Text(viewModel.reviewStatus.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
      
      Text(viewModel.reviewStatus.subtitle)
        .foregroundStyle(Colors.titleSecondary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      if viewModel.reviewStatus != .approved {
        FullWidthButton(
          type: .primary,
          title: "Check status",
          isDisabled: viewModel.isLoading,
          isLoading: $viewModel.isLoading
        ) {
          viewModel.onCheckStatusButtonTap()
        }
        .opacity(viewModel.reviewStatus == .rejected ? 0 : 1)
      }
      
      FullWidthButton(
        // Ignore `(status: .empty)`, this check applies to any unclear status
        type: (viewModel.reviewStatus == .inReview || viewModel.reviewStatus == .unclear(status: .empty)) ? .alternativeBordered : .primary,
        title: "Log out",
        isDisabled: viewModel.isLoading,
        isLoading: .constant(false)
      ) {
        viewModel.onLogoutButtonTap()
      }
      .opacity(viewModel.reviewStatus == .approved ? 0 : 1)
      
      FullWidthButton(
        type: .alternativeBordered,
        title: "Contact support",
        isDisabled: viewModel.isLoading,
        isLoading: .constant(false)
      ) {
        viewModel.onSupportButtonTap()
      }
      .opacity(viewModel.reviewStatus == .approved ? 0 : 1)
      
      if viewModel.reviewStatus == .approved {
        FullWidthButton(
          type: .primary,
          title: "Continue to Avalanche",
          isDisabled: false,
          isLoading: $viewModel.isLoading
        ) {
          viewModel.onContinueButtonTap()
        }
      }
    }
  }
}

// MARK: - Private Enums
extension ReviewStatusView {}
