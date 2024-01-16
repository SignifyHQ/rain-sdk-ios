import SwiftUI
import NetspendOnboarding
import LFLocalizable
import LFUtilities
import LFStyleGuide

public struct FundCardView: View {
  @StateObject private var viewModel: FundCardViewModel
  let onFinish: () -> Void
  
  public init(kind: MoveMoneyAccountViewModel.Kind, onFinish: @escaping () -> Void) {
    self.onFinish = onFinish
    _viewModel = StateObject(wrappedValue: FundCardViewModel(kind: kind))
  }
  
  public var body: some View {
    content
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .agreement(let data):
          AgreementView(
            viewModel: AgreementViewModel(fundingAgreement: data),
            onNext: {
            }, onDisappear: { isAcceptAgreement in
              self.viewModel.handleFundingAcceptAgreement(isAccept: isAcceptAgreement)
            }, shouldFetchCurrentState: false)
        }
      }
      .background(Colors.background.swiftUIColor)
  }
}

// MARK: - Private View Components
private extension FundCardView {
  var content: some View {
    VStack(spacing: 0) {
      GenImages.Images.fundCard.swiftUIImage
      
      VStack(spacing: 16) {
        Text(LFLocalizable.FundCard.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Text(LFLocalizable.FundCard.message)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .lineSpacing(1.25)
        actionsView
        Spacer()
        skipButton
      }
      .multilineTextAlignment(.center)
      .padding(.bottom, 16)
      .padding(.horizontal, 30)
    }
  }
  
  var actionsView: some View {
    AddFundsView(
      viewModel: viewModel.addFundsViewModel,
      achInformation: $viewModel.achInformation,
      isDisableView: $viewModel.isDisableView,
      options: [.debitDepositFunds, .oneTime]
    )
    .padding(.top, 8)
    .fixedSize(horizontal: false, vertical: true)
  }
  
  var skipButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Skip.title,
      isDisable: false,
      type: .secondary
    ) {
      onFinish()
    }
  }
}
