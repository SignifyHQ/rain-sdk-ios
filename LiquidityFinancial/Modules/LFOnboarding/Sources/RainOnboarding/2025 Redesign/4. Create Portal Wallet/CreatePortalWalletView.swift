import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct CreatePortalWalletView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: CreatePortalWalletViewModel
  
  @State var safariNavigation: CreatePortalWalletViewModel.SafariNavigation?
  
  public init(
    viewModel: CreatePortalWalletViewModel
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
      
      termsView
      
      buttonGroup
    }
    .padding(.top, 8)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      },
      isBackButtonHidden: true
    )
    .toast(
      data: $viewModel.currentToast
    )
    .withLoadingIndicator(
      isShowing: $viewModel.isLoading
    )
    .disabled(viewModel.isLoading)
    .fullScreenCover(
      item: $safariNavigation
    ) { type in
      switch type {
      case .userAgreement:
        if let url = viewModel.getURL(tappedString: viewModel.userAgreement) {
          SFSafariViewWrapper(url: url)
        }
      case .privacyPolicy:
        if let url = viewModel.getURL(tappedString: viewModel.privacyPolicy) {
          SFSafariViewWrapper(url: url)
        }
      case .regulatoryDisclosures:
        if let url = viewModel.getURL(tappedString: viewModel.regulatoryDisclosures) {
          SFSafariViewWrapper(url: url)
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
private extension CreatePortalWalletView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView
      
      portalLogoView
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var progressView: some View {
    SegmentedProgressBar(
      totalSteps: 8,
      currentStep: .constant(2)
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text("Create your wallet")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Text("Avalanche Card has partnered with Portal to\noffer wallets.")
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var portalLogoView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      HStack(
        spacing: 12
      ) {
        GenImages.Images.icoPortal.swiftUIImage
        
        Spacer()
      }
    }
  }
  
  private var termsView: some View {
    VStack(
      alignment: .leading,
      spacing: 12
    ) {
      Text("I accept the following terms")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
      
      termsLine(
        text: "l agree to the Portal Services User Agreement, and\nI have read and understand the Portal Privacy Policy\nand Regulatory Disclosures.",
        isChecked: $viewModel.areTermsAgreed
      )
    }
  }
  
  private func termsLine(
    text: String,
    isChecked: Binding<Bool>
  ) -> some View {
    HStack(
      alignment: .top,
      spacing: 8
    ) {
      checkBoxImage(
        isChecked: isChecked
      )
      .onTapGesture {
        isChecked.wrappedValue.toggle()
      }
      
      TextTappable(
        text: text,
        textAlignment: .left,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [
          viewModel.userAgreement,
          viewModel.privacyPolicy,
          viewModel.regulatoryDisclosures
        ],
        style: .underlined(Colors.titlePrimary.color)
      ) { tappedString in
        switch tappedString {
        case viewModel.userAgreement:
          safariNavigation = .userAgreement
        case viewModel.privacyPolicy:
          safariNavigation = .privacyPolicy
        case viewModel.regulatoryDisclosures:
          safariNavigation = .regulatoryDisclosures
          
        default: break
        }
      }
    }
    .frame(
      height: 47
    )
  }
  
  @ViewBuilder
  private func checkBoxImage(
    isChecked: Binding<Bool>
  ) -> some View {
    if isChecked.wrappedValue {
      GenImages.Images.icoCheckboxSelected.swiftUIImage
    } else {
      GenImages.Images.icoCheckboxUnselected.swiftUIImage
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
extension CreatePortalWalletView {}
