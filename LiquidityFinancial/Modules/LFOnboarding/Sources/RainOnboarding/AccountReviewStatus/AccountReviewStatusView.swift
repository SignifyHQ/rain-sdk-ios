import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import Services
import BaseOnboarding

struct AccountReviewStatusView: View {
  @StateObject var viewModel: AccountReviewStatusViewModel
  
  init(viewModel: AccountReviewStatusViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    makeContentView(with: viewModel.state)
      .track(name: String(describing: type(of: self)))
      .background(Colors.background.swiftUIColor)
      .navigationBarBackButtonHidden()
      .defaultToolBar(icon: .support, openSupportScreen: {
        viewModel.openSupportScreen()
      })
      .fullScreenCover(item: $viewModel.presentation) { item in
        switch item {
        case let .idv(url):
          IdentityVerificationView(url: url) {
            viewModel.idvComplete()
          }
        }
      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .popup(item: $viewModel.popup) { popup in
        switch popup {
        case .inReview:
          inReviewPopup
        case .magic:
          magicPopup
        }
      }
  }
}

// MARK: - View Components
private extension AccountReviewStatusView {
  @ViewBuilder
  func makeContentView(with state: AccountReviewStatus) -> some View {
    switch state {
    case .idle:
      loadingView
    case .reject,
        .identityVerification,
        .inReview,
        .missingInformation,
        .unclear:
      informationView(info: state.accountReviewInformation)
    }
  }
  
  var loadingView: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        ProgressView()
          .progressViewStyle(
            CircularProgressViewStyle(tint: Colors.primary.swiftUIColor)
          )
        Spacer()
      }
      Spacer()
    }
  }
  
  @ViewBuilder
  func informationView(info: AccountReviewInformation?) -> some View {
    if let info {
      VStack {
        Spacer()
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .scaledToFit()
          .frame(124)
          .onLongPressGesture(minimumDuration: 2) {
            viewModel.openMagicPopup()
          }
        contextView(info: info)
        Spacer()
        buttonGroup(info: info)
      }
      .padding(.horizontal, 30)
      .background(Colors.background.swiftUIColor)
    }
  }
  
  func contextView(info: AccountReviewInformation) -> some View {
    VStack(spacing: 12) {
      Text(info.title)
        .padding()
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .multilineTextAlignment(.center)
      Text(info.message)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.center)
    }
    .lineSpacing(1.17)
  }
  
  func buttonGroup(info: AccountReviewInformation) -> some View {
    VStack(spacing: 12) {
      if let secondary = info.secondary {
        FullSizeButton(
          title: secondary,
          isDisable: false,
          type: .secondary
        ) {
          viewModel.secondaryAction()
        }
      }
      
      if let primary = info.primary {
        FullSizeButton(
          title: primary,
          isDisable: false,
          isLoading: $viewModel.isLoading
        ) {
          viewModel.primaryAction()
        }
      }
      
      FullSizeButton(
        title: L10N.Common.Profile.Logout.title,
        isDisable: false,
        isLoading: .constant(false),
        type: .destructive
      ) {
        viewModel.forcedLogout()
      }
    }
    .padding(.bottom, 16)
  }
  
  var magicPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Popup.ToolKit.passReviewTitle,
      message: L10N.Common.Popup.ToolKit.passReviewMessage,
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.onMagicPopupPrimaryButtonTapped()
      },
      secondary: .init(text: L10N.Common.Button.Skip.title) {
        viewModel.closePopup()
      }
    )
  }
  
  var inReviewPopup: some View {
    LiquidityAlert(
      title: L10N.Common.ApplicationReviewStatus.InReview.Popup.title,
      message: L10N.Common.ApplicationReviewStatus.InReview.Popup.message,
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.closePopup()
      }
    )
  }
}
