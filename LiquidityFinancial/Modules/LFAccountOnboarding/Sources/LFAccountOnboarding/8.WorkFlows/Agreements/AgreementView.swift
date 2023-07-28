import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import OnboardingDomain

public struct AgreementView: View {
  @Environment(\.openURL)
  var openURL
  @StateObject private var viewModel = AgreementViewModel()
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 24) {
      headerTitle

      ZStack {
        HStack {
          GenImages.Images.icLogo.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
          Spacer()
          GenImages.CommonImages.netspendLogo.swiftUIImage
            .scaledToFit()
            .frame(width: 173, height: 87)
        }
        .padding(.horizontal, 20)
        .frame(height: 112)
        .frame(maxWidth: 600)
      }
      .foregroundColor(.clear)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(12)
      
      Spacer()
      VStack(alignment: .leading, spacing: 0) {
        conditionCell(
          isSelected: $viewModel.isAgreedNetSpendCondition,
          condition: viewModel.netspendCondition
        )
        conditionCell(
          isSelected: $viewModel.isAgreedPathwardCondition,
          condition: viewModel.pathwardCondition
        )
      }
      continueButton
    }
    .padding(.bottom, 16)
    .padding(.top, 30)
    .padding(.horizontal, 30)
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $viewModel.isNavigationPersonalInformation) {
      PersonalInformationView()
    }
  }
}

// MARK: View Components
private extension AgreementView {
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.Question.Screen.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(
        LFLocalizable.Question.Screen.description(LFUtility.appName)
      )
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
  }
  
  func conditionCell(isSelected: Binding<Bool>, condition: ServiceCondition) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Button {
        isSelected.wrappedValue.toggle()
      } label: {
        Group {
          if isSelected.wrappedValue {
            GenImages.CommonImages.termsCheckboxSelected.swiftUIImage
              .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
          } else {
            GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
              .foregroundColor(Colors.Buttons.unhighlightButton.swiftUIColor)
          }
        }
      }
      .frame(24)
      .offset(y: 8)
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.25))
      TextTappable(
        text: condition.message,
        links: Array(condition.attributeInformation.keys),
        style: .underlined
      ) { tappedString in
        guard let url = URL(string: viewModel.getURL(tappedString: tappedString)) else {
          return
        }
        openURL(url)
      }
    }
    .frame(maxHeight: 90)
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: viewModel.isDisableButton
    ) {
      viewModel.isNavigationPersonalInformation = true
    }
  }
}
