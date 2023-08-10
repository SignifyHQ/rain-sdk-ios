import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct KYCStatusView: View {
  @StateObject var viewModel: KYCStatusViewModel
  @State private var showPopup = false
  
  init(viewModel: KYCStatusViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    makeContentView(with: viewModel.state)
      .background(Colors.background.swiftUIColor)
      .navigationBarBackButtonHidden()
      // .track(name: String(describing: type(of: self))) TODO: Will be implemented later
      .defaultToolBar(icon: .intercom, openIntercom: {
        viewModel.openIntercom()
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
      .popup(isPresented: $showPopup) {
        magicPopup
      }
  }
}

  // MARK: - View Components
private extension KYCStatusView {
  @ViewBuilder
  func makeContentView(with state: KYCState) -> some View {
    switch state {
    case .idle:
      loadingView
    case .inVerify:
      kycWaitView
    case .declined, .pendingIDV, .inReview, .missingInfo:
      informationView(info: state.kycInformation)
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
  
  @ViewBuilder func informationView(info: KYCInformation?) -> some View {
    if let info {
      VStack {
        Spacer()
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .scaledToFit()
          .frame(width: 124, height: 124)
          .onLongPressGesture(minimumDuration: 2) {
            showPopup = true
          }
        contextView(info: info)
        Spacer()
        buttonGroup(info: info)
      }
      .padding(.horizontal, 30)
      .background(Colors.background.swiftUIColor)
    }
  }
  
  func contextView(info: KYCInformation) -> some View {
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
  
  func buttonGroup(info: KYCInformation) -> some View {
    VStack(spacing: 12) {
      if let secondary = info.secondary {
        FullSizeButton(title: secondary, isDisable: false, type: .secondary) {
          viewModel.secondaryAction()
        }
      }
      FullSizeButton(title: info.primary, isDisable: false, isLoading: $viewModel.isLoading) {
        viewModel.primaryAction()
      }
    }
    .padding(.bottom, 16)
  }
  
  var kycWaitView: some View {
    Colors.background.swiftUIColor
      .popup(isPresented: .constant(true)) {
        waitingPopup
      }
  }
  
  var waitingPopup: some View {
    PopupAlert {
      VStack(spacing: 32) {
        GradientIndicatorView(
          isVisible: .constant(true),
          colors: [Color.clear, Colors.primary.swiftUIColor],
          lineWidth: 10
        )
        .frame(width: 56, height: 56)
        
        VStack(spacing: 12) {
          Text(LFLocalizable.KycStatus.WaitingVerification.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
            .foregroundColor(Colors.label.swiftUIColor)
          
          Text(LFLocalizable.KycStatus.WaitingVerification.message)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .lineSpacing(1.7)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
      }
      .padding(.vertical, 20)
    }
  }
  
  var magicPopup: some View {
    LiquidityAlert(
      title: "[Tool Kit] - Pass review from Dashboard.",
      message: "Click ok and we call service help you can pass a review of the Dashboard.",
      primary: .init(text: LFLocalizable.Button.Ok.title) {
        showPopup = false
        viewModel.magicPassKYC()
      },
      secondary: .init(text: LFLocalizable.Button.Skip.title, action: {
        showPopup = false
      })
    )
  }
}
