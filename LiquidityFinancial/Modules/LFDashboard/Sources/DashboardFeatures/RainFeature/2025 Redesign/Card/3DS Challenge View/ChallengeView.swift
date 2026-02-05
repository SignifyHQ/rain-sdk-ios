import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct ChallengeView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: ChallengeViewModel
  
  private var onDimissed: (() -> Void)?
  
  public init(
    viewModel: ChallengeViewModel,
    onDimissed: (() -> Void)?
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onDimissed = onDimissed
  }
  
  public var body: some View {
    VStack(
      spacing: 32
    ) {
      headerView
      
      subtitleView
      
      transactionDetails
      
      buttonGroup
    }
    .padding(.top, 24)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundDark.swiftUIColor)
    .toast(
      data: $viewModel.currentToast
    )
    .onChange(
      of: viewModel.shouldDismiss3dsChallengeSheet
    ) {
      dismiss()
      onDimissed?()
    }
  }
}

// MARK: - View Components
private extension ChallengeView {
  var headerView: some View {
    HStack {
      Spacer()
      
      Text(L10N.Common.Pending3DSChallenge.Popup.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Spacer()
    }
  }
  
  var subtitleView: some View {
    Text(L10N.Common.Pending3DSChallenge.Popup.subtitle(viewModel.displayLast4))
      .foregroundStyle(Colors.titlePrimary.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)
      .fixedSize(horizontal: false, vertical: true)
  }
  
  var transactionDetails: some View {
    VStack(spacing: 12) {
      detailItem(title: L10N.Common.Pending3DSChallenge.Details.Amount.title, value: viewModel.displayPurchaseAmount)
      detailItem(title: L10N.Common.Pending3DSChallenge.Details.Merchant.title, value: viewModel.displayMerchantName)
      detailItem(title: L10N.Common.Pending3DSChallenge.Details.Location.title, value: viewModel.displayMerchantCountry)
    }
  }
  
  func detailItem(title: String, value: String) -> some View {
    VStack(spacing: 12) {
      HStack {
        Text(title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
        
        Spacer()
        
        Text(value)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      }
      
      lineView
    }
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: L10N.Common.Common.Verify.Button.title,
        isDisabled: viewModel.areButtonsDisabled,
        isLoading: $viewModel.isApproving
      ) {
        viewModel.onDecisionButtonTap(decision: .approve)
      }
      
      FullWidthButton(
        type: .secondary,
        title: L10N.Common.Common.Decline.Button.title,
        isDisabled: viewModel.areButtonsDisabled,
        isLoading: $viewModel.isDeclining
      ) {
        viewModel.onDecisionButtonTap(decision: .decline)
      }
    }
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
