import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import GeneralFeature

struct ChangeRewardView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ChangeRewardViewModel
  
  init(availableCurrencies: [AssetType], selectedRewardCurrency: AssetType?) {
    _viewModel = .init(
      wrappedValue: ChangeRewardViewModel(
        availableCurrencies: availableCurrencies,
        selectedRewardCurrency: selectedRewardCurrency
      )
    )
  }
  
  var body: some View {
    content
      .disabled(viewModel.isChangingCurrency)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .currentRewards:
          CurrentRewardView()
        }
      }
      .defaultToolBar(navigationTitle: L10N.Common.ChangeRewardView.title)
      .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension ChangeRewardView {
  var content: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(L10N.Common.ChangeRewardView.caption)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      VStack(spacing: 10) {
        ForEach(viewModel.availableCurrencies, id: \.self) { assetType in
          assetCell(assetType: assetType)
        }
      }
      Spacer()
      buttonsView
    }
    .padding(.top, 20)
    .padding(.horizontal, 30)
  }
  
  var buttonsView: some View {
    VStack(spacing: 16) {
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: L10N.Common.ChangeRewardView.currentRewards,
        value: nil,
        fontSize: Constants.FontSize.medium.value
      ) {
        viewModel.onClickedCurrentRewardsButton()
      }
      FullSizeButton(
        title: L10N.Common.Button.Save.title,
        isDisable: viewModel.isDisableButton,
        isLoading: $viewModel.isChangingCurrency
      ) {
        viewModel.onSaveRewardCurrency()
      }
    }
    .padding(.bottom, 24)
  }
  
  func assetCell(assetType: AssetType) -> some View {
    Button {
      viewModel.onSelectedRewardCurrency(assetType: assetType)
    } label: {
      HStack(spacing: 8) {
        assetType.icon
        Text(assetType.symbol ?? "N/A")
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        Spacer()
        circleBoxView(isSelected: assetType == viewModel.selectedRewardCurrency)
        .padding(.trailing, 8)
      }
      .padding(.horizontal, 16)
      .frame(height: 56)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
    }
  }
  
  @ViewBuilder
  func circleBoxView(isSelected: Bool) -> some View {
    if isSelected {
      ZStack(alignment: .center) {
        Circle()
          .fill(Colors.primary.swiftUIColor)
          .frame(width: 20, height: 20)
        GenImages.CommonImages.icCheckmark.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
    } else {
      Circle()
        .stroke(Colors.label.swiftUIColor.opacity(0.75), lineWidth: 1)
        .frame(width: 20, height: 20)
    }
  }
}
