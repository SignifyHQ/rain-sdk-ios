import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import OnboardingDomain
import LFServices
import BaseOnboarding
import Factory

public struct AgreementView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) var openURL
  @StateObject var viewModel: AgreementViewModel
  
  var shouldFetchCurrentState: Bool = false
  var onNext: (() -> Void)?
  var onDisappear: ((_ isAcceptAgreement: Bool) -> Void)?
  var contenViewFactory: NSContentViewFactory
  
  public init(
    viewModel: AgreementViewModel,
    onNext: (() -> Void)? = nil,
    onDisappear: ((_ isAcceptAgreement: Bool) -> Void)? = nil,
    shouldFetchCurrentState: Bool = true,
    container: Container = Container.shared
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.shouldFetchCurrentState = shouldFetchCurrentState
    self.onNext = onNext
    self.onDisappear = onDisappear
    self.contenViewFactory = container.contenViewFactory.callAsFunction(EnvironmentManager())
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(spacing: 24) {
        headerTitle
        netspendLogo
      }
      Spacer()
      termAndConditions
      continueButton
      footer
    }
    .padding(.bottom, 16)
    .padding(.top, 20)
    .padding(.horizontal, 30)
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $viewModel.isNavigationPersonalInformation) {
      contenViewFactory.createView(type: .infomation)
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onDisappear {
      self.onDisappear?(viewModel.isAcceptAgreement)
    }
    .onAppear {
      self.viewModel.checkData(needBufferData: false)
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension AgreementView {
  @ViewBuilder var footer: some View {
    if viewModel.isTransferTerms {
      Text(LFLocalizable.Question.TransferTerms.diclosure)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .multilineTextAlignment(.leading)
        .padding(.trailing, 20)
    }
  }
  
  @ViewBuilder var netspendLogo: some View {
    if !viewModel.isTransferTerms {
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
      }
      .frame(height: 112)
      .frame(maxWidth: 600)
      .foregroundColor(.clear)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(12)
    }
  }
  
  var loadingView: some View {
    VStack {
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
    }
    .frame(maxWidth: .infinity)
  }
  
  var termAndConditions: some View {
    VStack(spacing: 0) {
      if viewModel.isLoading {
        loadingView
      } else {
        if let condition = viewModel.condition {
          conditionCell(
            condition: condition
          )
        } else {
          VStack(alignment: .leading, spacing: 0) {
            ForEach($viewModel.conditions) { condition in
              conditionCell(
                condition: condition.wrappedValue
              )
            }
          }
        }
      }
    }
  }
  
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(viewModel.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(viewModel.description)
        .multilineTextAlignment(.leading)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
    .padding(.trailing, 30)
  }
  
  func conditionCell(condition: ServiceConditionModel) -> some View {
    HStack(alignment: .top, spacing: 8) {
      Group {
        if condition.selected {
          GenImages.Images.termsCheckboxSelected.swiftUIImage
            .onTapGesture {
              viewModel.updateSelectedAgreementItem(agreementID: condition.id, selected: !condition.selected)
            }
        } else {
          GenImages.Images.termsCheckboxDeselected.swiftUIImage
            .onTapGesture {
              viewModel.updateSelectedAgreementItem(agreementID: condition.id, selected: !condition.selected)
            }
        }
      }
      .frame(28)
      .offset(y: 6)
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
      .frame(minHeight: 80)
      .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: viewModel.isDisableButton,
      isLoading: $viewModel.isAcceptAgreementLoading
    ) {
      if let onNext = onNext {
        viewModel.apiPostAgreements {
          if shouldFetchCurrentState {
            Task { @MainActor in
              self.viewModel.isAcceptAgreementLoading = true
              await viewModel.onboardingFlowCoordinator.apiFetchCurrentState()
              self.viewModel.isAcceptAgreementLoading = false
              onNext()
            }
          } else {
            dismiss()
            onNext()
          }
        }
      } else {
        viewModel.continute()
      }
    }
  }
}
