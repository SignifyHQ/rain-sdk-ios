import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI
import Factory

struct YourAccountView: View {
  @Environment(\.openURL) var openURL
  @Injected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator
  @StateObject private var viewModel: YourAccountViewModel = YourAccountViewModel()
  
  init(
    viewModel: YourAccountViewModel = YourAccountViewModel()
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        title
        terms
      }
      .padding(.horizontal, 30)
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
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          solidOnboardingFlowCoordinator.set(route: .selecteReward)
        } label: {
          CircleButton(style: .left)
        }
      }
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
              .resizable()
              .frame(width: 24, height: 24)
          } else {
            GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
              .resizable()
              .frame(width: 24, height: 24)
              .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
          }
        }
        .onTapGesture {
          viewModel.isEsignatureAccepted.toggle()
        }
        .padding(.bottom, 5)
        
        TextTappable(
          text: viewModel.esignString,
          fontSize: Constants.FontSize.ultraSmall.value,
          links: [viewModel.esignLink],
          style: .underlined(Colors.label.color)
        ) { tappedString in
          guard let url = viewModel.getUrl(for: tappedString) else { return }
          openURL(url)
        }
        .frame(height: 37)
      }
      
      HStack(spacing: 5) {
        Group {
          if viewModel.isTermsPrivacyAccepted {
            GenImages.Images.termsCheckboxSelected.swiftUIImage
              .resizable()
              .frame(width: 24, height: 24)
          } else {
            GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
              .resizable()
              .frame(width: 24, height: 24)
              .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
          }
        }
        .onTapGesture {
          viewModel.isTermsPrivacyAccepted.toggle()
        }
        .padding(.bottom, 35)

        TextTappable(
          text: viewModel.agreementString,
          fontSize: Constants.FontSize.ultraSmall.value,
          links: [viewModel.consumerLink, viewModel.termsLink, viewModel.privacyLink],
          style: .underlined(Colors.label.color)
        ) { tappedString in
          guard let url = viewModel.getUrl(for: tappedString) else { return }
          openURL(url)
        }
        .frame(height: 67)
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
