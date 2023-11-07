import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct YourAccountView: View {
  @Environment(\.openURL) var openURL
  @StateObject private var viewModel: YourAccountViewModel = YourAccountViewModel()
  
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        title
        terms
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 12)
      
      agreements
        .padding(.horizontal, 30)
      
      continueButton
    }
    .frame(maxWidth: .infinity)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      }
    )
    .navigationLink(isActive: $viewModel.shouldContinue) {
      PatriotActView()
    }
  }
}

extension YourAccountView {
  private var title: some View {
    Text(LFLocalizable.YourAccount.title)
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .padding(.bottom, 12)
  }
  
  private var terms: some View {
    Group {
      Text(LFLocalizable.YourAccount.subtitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(1.33)
        .multilineTextAlignment(.leading)
      
      Spacer()
      
      Text(LFLocalizable.YourAccount.body)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(1.33)
        .multilineTextAlignment(.leading)
    }
  }
  
  private var agreements: some View {
    VStack {
      HStack(spacing: 5) {
        Group {
          if viewModel.isEsignatureAccepted {
            GenImages.Images.termsCheckboxSelected.swiftUIImage
              .resizable().frame(width: 24, height: 24)
          } else {
            GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
              .resizable().frame(width: 24, height: 24)
              .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
          }
        }
        .onTapGesture {
          viewModel.isEsignatureAccepted.toggle()
        }
        .padding(.bottom, 5)
        let agreementString = LFLocalizable.YourAccount.Agreements.esignature
        let link = LFLocalizable.YourAccount.Links.esignature

        TextTappable(
          text: agreementString,
          fontSize: Constants.FontSize.ultraSmall.value,
          links: [link],
          style: .underlined(Colors.label.color)
        ) { tappedString in
          guard let url = URL(string: LFUtilities.termsURL) else { return } // Todo(Volo): - Replace with actual URL from config
          openURL(url)
        }
        .frame(height: 40)
      }
      
      HStack(spacing: 5) {
        Group {
          if viewModel.isTermsPrivacyAccepted {
            GenImages.Images.termsCheckboxSelected.swiftUIImage
              .resizable().frame(width: 24, height: 24)
          } else {
            GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
              .resizable().frame(width: 24, height: 24)
              .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
          }
        }
        .onTapGesture {
          viewModel.isTermsPrivacyAccepted.toggle()
        }
        .padding(.bottom, 35)
        let agreementString = LFLocalizable.YourAccount.Agreements.consumerTermsConditions
        let consumerLink = LFLocalizable.YourAccount.Links.consumerCardholder
        let termsLink = LFLocalizable.YourAccount.Links.terms
        let privacyLink = LFLocalizable.YourAccount.Links.privacy

        TextTappable(
          text: agreementString,
          fontSize: Constants.FontSize.ultraSmall.value,
          links: [consumerLink, termsLink, privacyLink],
          style: .underlined(Colors.label.color)
        ) { tappedString in
          guard let url = URL(string: LFUtilities.termsURL) else { return } // Todo(Volo): - Replace with actual URL from config
          openURL(url)
        }
        .frame(height: 70)
      }
    }
  }
  
  private var continueButton: some View {
    VStack(spacing: 0) {
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !(viewModel.isEsignatureAccepted && viewModel.isTermsPrivacyAccepted),
        type: .primary
      ) {
        viewModel.shouldContinue = true
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
}
