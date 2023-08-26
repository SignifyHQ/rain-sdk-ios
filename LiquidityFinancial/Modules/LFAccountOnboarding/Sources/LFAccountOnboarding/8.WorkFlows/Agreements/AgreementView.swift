import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import OnboardingDomain

public struct AgreementView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) var openURL
  @StateObject private var viewModel: AgreementViewModel
  
  var onNext: (() -> Void)?
  var onDisappear: ((_ isAcceptAgreement: Bool) -> Void)?
  public init(viewModel: AgreementViewModel,
              onNext: (() -> Void)? = nil,
              onDisappear: ((_ isAcceptAgreement: Bool) -> Void)? = nil) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onNext = onNext
    self.onDisappear = onDisappear
  }
  
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
      
      Group {
        if viewModel.isLoading {
          loadingView
        } else {
          VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { _ in
              ForEach($viewModel.agreements) { agreement in
                conditionCell(
                  condition: agreement.wrappedValue
                )
              }
            }
            .padding(0)
          }
        }
      }
      
      continueButton
    }
    .padding(.bottom, 16)
    .padding(.top, 40)
    .padding(.horizontal, 30)
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $viewModel.isNavigationPersonalInformation) {
      PersonalInformationView()
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .overlay(alignment: .topLeading) {
      if onNext != nil {
        Button {
          dismiss()
        } label: {
          CircleButton(style: .xmark)
        }
        .padding(.top, -10)
        .padding(.leading, 16)
        .disabled(viewModel.isAcceptAgreementLoading)
      }
    }
    .onDisappear {
      self.onDisappear?(viewModel.isAcceptAgreement)
    }
    .navigationBarBackButtonHidden()
  }
  
  private var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: View Components
private extension AgreementView {
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.Question.Screen.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(
        LFLocalizable.Question.Screen.description(LFUtility.appName)
      )
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
  }
  
  func conditionCell(condition: ServiceConditionModel) -> some View {
    HStack(alignment: .top, spacing: 8) {
      Button {
        viewModel.updateSelectedAgreementItem(agreementID: condition.id, selected: !condition.selected)
      } label: {
        Group {
          if condition.selected {
            GenImages.CommonImages.termsCheckboxSelected.swiftUIImage
              .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
          } else {
            GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
              .foregroundColor(Colors.Buttons.unhighlightButton.swiftUIColor)
          }
        }
      }
      .frame(28)
      .offset(y: 10)
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.25))
      TextTappable(
        text: condition.message,
        links: Array(condition.attributeInformation.keys),
        style: .underlined(Colors.label.color)
      ) { tappedString in
        guard let url = URL(string: viewModel.getURL(tappedString: tappedString)) else {
          return
        }
        openURL(url)
      }
    }
    .frame(minHeight: 90)
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: viewModel.isDisableButton,
      isLoading: $viewModel.isAcceptAgreementLoading
    ) {
      if let onNext = onNext {
        viewModel.apiPostAgreements {
          Task { @MainActor in
            self.viewModel.isLoading = true
            await viewModel.onboardingFlowCoordinator.apiFetchCurrentState()
            self.viewModel.isLoading = false
            onNext()
          }
        }
      } else {
        viewModel.continute()
      }
    }
  }
}
