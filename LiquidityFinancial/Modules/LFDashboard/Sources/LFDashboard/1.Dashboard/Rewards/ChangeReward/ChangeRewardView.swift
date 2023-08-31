import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFTransaction
import DashboardRepository

struct ChangeRewardView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ChangeRewardViewModel
  
  init(assetModels: [AssetModel], selectedAssetModel: AssetModel) {
    _viewModel = .init(
      wrappedValue: ChangeRewardViewModel(
        assetModels: assetModels,
        selectedAssetModel: selectedAssetModel
      )
    )
  }
  
  var body: some View {
    content
      .defaultToolBar(navigationTitle: LFLocalizable.ChangeRewardView.title)
      .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension ChangeRewardView {
  var content: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(LFLocalizable.ChangeRewardView.caption)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
      VStack(spacing: 10) {
        ForEach(viewModel.assetModels, id: \.self) { asset in
          assetCell(asset: asset)
        }
      }
      Spacer()
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: LFLocalizable.ChangeRewardView.currentRewards,
        value: nil
      ) {
        dismiss()
      }
      .padding(.bottom, 24)
    }
    .padding(.top, 20)
    .padding(.horizontal, 30)
  }
  
  @ViewBuilder func assetCell(asset: AssetModel) -> some View {
    if let assetType = asset.type {
      Button {
        // TODO: Change assets later
      } label: {
        HStack(spacing: 8) {
          assetType.image
          Text(assetType.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          Spacer()
          circleBoxView(isSelected: asset.type == viewModel.selectedAssetModel.type)
          .padding(.trailing, 8)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
      }
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
