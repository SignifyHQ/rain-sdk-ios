import Factory
import LFStyleGuide
import LFUtilities
import LFLocalizable
import SwiftUI

public struct CardTermsView: View {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @StateObject var viewModel: CardTermsViewModel
  
  @State var openSafariType: CardTermsViewModel.OpenSafariType?
  
  public init(
    viewModel: CardTermsViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(
      alignment: .leading,
      spacing: 28
    ) {
      headerTitle
      
      Spacer()
      
      footerView
    }
    .padding(.bottom, 16)
    .padding(.top, 8)
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .fullScreenCover(item: $openSafariType) { type in
      switch type {
      case .accountDisclosures:
        if let url = viewModel.getURL(tappedString: viewModel.accountDisclosures) {
          SFSafariViewWrapper(url: url)
        }
      case .cardTerms:
        if let url = viewModel.getURL(tappedString: viewModel.cardTerms) {
          SFSafariViewWrapper(url: url)
        }
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - Header View Components
private extension CardTermsView {
  var headerTitle: some View {
    Text(L10N.Common.Term.CardTerms.title)
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
  }
}

// MARK: Footer View Components
private extension CardTermsView {
  var footerView: some View {
    VStack(spacing: 5) {
      termsView
      
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: !viewModel.isButtonEnabled,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.isLoading = true
        viewModel.acceptTerms()
      }
    }
    .padding(.bottom, 12)
  }
  
  @ViewBuilder
  private func checkBoxImage(
    isChecked: Binding<Bool>
  ) -> some View {
    if isChecked.wrappedValue {
      GenImages.Images.termsCheckboxSelected.swiftUIImage
    } else {
      GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
        .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
    }
  }
  
  private var termsView: some View {
    VStack {
      if viewModel.isUS {
        termsLine(text: L10N.Common.Term.AccountDisclosures.description, isChecked: $viewModel.isAccountDisclosureAgreed)
      }
      
      termsLine(text: L10N.Common.Term.CardTerms.description, isChecked: $viewModel.areCardTermsAgreed)
      termsLine(text: L10N.Common.Term.AccurateInformation.description, isChecked: $viewModel.isInfoAccurateAgreed, height: 50)
      termsLine(text: L10N.Common.Term.Acknowledgement.description, isChecked: $viewModel.isAcknowledgmentAgreed, height: 35)
    }
    .padding(.bottom, 5)
  }
  
  private func termsLine(
    text: String,
    isChecked: Binding<Bool>,
    height: CGFloat = 10
  ) -> some View {
    HStack(
      alignment: .center,
      spacing: 0
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
          viewModel.cardTerms
        ],
        style: .fillColor(Colors.termAndPrivacy.color)
      ) { tappedString in
        switch tappedString {
        case viewModel.accountDisclosures:
          openSafariType = .accountDisclosures
        case viewModel.cardTerms:
          openSafariType = .cardTerms
          
        default: break
        }
      }
      .frame(height: height)
    }
  }
}
