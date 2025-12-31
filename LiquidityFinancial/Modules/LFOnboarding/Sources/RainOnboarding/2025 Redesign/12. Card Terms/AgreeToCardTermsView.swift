import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct AgreeToCardTermsView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: AgreeToCardTermsViewModel
  
  @State var safariNavigation: AgreeToCardTermsViewModel.SafariNavigation?
  
  public init(
    viewModel: AgreeToCardTermsViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack(
        spacing: 32
      ) {
        contentView
        
        termsView
        
        Spacer()
        
        buttonGroup
      }
      .padding(.top, 4)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
    }
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      buttonTypes: [],
      isBackButtonHidden: true
    )
    .toast(
      data: $viewModel.currentToast
    )
    .disabled(viewModel.isLoading)
    .fullScreenCover(
      item: $safariNavigation
    ) { type in
      switch type {
      case .accountDisclosures:
        if let url = viewModel.getURL(tappedString: viewModel.accountDisclosures) {
          SFSafariViewWrapper(url: url)
        }
      case .cardTerms:
        if let url = viewModel.getURL(tappedString: viewModel.cardTerms) {
          SFSafariViewWrapper(url: url)
        }
      case .privacyPolicy:
        if let url = viewModel.getURL(tappedString: viewModel.privacyPolicy) {
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
private extension AgreeToCardTermsView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      HStack {
        Text("Agree to card terms")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
      }
    }
  }
  
  private var termsView: some View {
    VStack(
      alignment: .leading,
      spacing: 12
    ) {
      termsLine(
        text: viewModel.selectedCountry.isUnitedStates ? "I accept the Opening Account Privacy Disclosures,\nCard Terms and Issuer Privacy Policy." : "I accept the Card Terms and Issuer Privacy Policy.",
        isChecked: $viewModel.areCardTermsAgreed,
        height: viewModel.selectedCountry.isUnitedStates ? 32 : 22
      )
      
      termsLine(
        text: "I certify that the information I have provided is\naccurate and I will abide by all the rules and\nrequirements of my Avalanche Card.",
        isChecked: $viewModel.isInfoAccurateAgreed,
        height: 47
      )
      
      termsLine(
        text: "I acknowledge that I was not solicited for this\nproduct.",
        isChecked: $viewModel.isAcknowledgmentAgreed,
        height: 32
      )
    }
  }
  
  private func termsLine(
    text: String,
    isChecked: Binding<Bool>,
    height: CGFloat
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
          viewModel.accountDisclosures,
          viewModel.cardTerms,
          viewModel.privacyPolicy
        ],
        style: .underlined(Colors.titlePrimary.color)
      ) { tappedString in
        switch tappedString {
        case viewModel.accountDisclosures:
          safariNavigation = .accountDisclosures
        case viewModel.cardTerms:
          safariNavigation = .cardTerms
        case viewModel.privacyPolicy:
          safariNavigation = .privacyPolicy
          
        default: break
        }
      }
    }
    .frame(
      height: height
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
extension AgreeToCardTermsView {}
