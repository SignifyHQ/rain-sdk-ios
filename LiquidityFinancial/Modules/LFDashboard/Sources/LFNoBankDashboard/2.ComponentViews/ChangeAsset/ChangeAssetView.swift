import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import BaseDashboard

struct ChangeAssetView: View {
  @Binding var selectedAsset: AssetType
  let balance: Double
  let assets: [AssetModel]

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(LFLocalizable.ChangeAsset.Screen.message)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      VStack(spacing: 10) {
        ForEach(assets, id: \.self) { asset in
          assetCell(asset: asset)
        }
      }
      Spacer()
    }
    .padding(.top, 24)
    .padding(.horizontal, 30)
    .frame(maxWidth: .infinity)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(navigationTitle: LFLocalizable.ChangeAsset.Screen.title)
  }
}

// MARK: - View Components
private extension ChangeAssetView {
  @ViewBuilder func assetCell(asset: AssetModel) -> some View {
    if let assetType = asset.type {
      Button {
        selectedAsset = assetType
      } label: {
        HStack(spacing: 8) {
          assetType.image
          Text(assetType.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          Spacer()
          VStack(alignment: .trailing, spacing: 2) {
            Text(asset.availableBalanceFormatted)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.black.swiftUIFont(size: Constants.FontSize.medium.value))
            if let bottomBalance = asset.availableUsdBalanceFormatted {
              Text(bottomBalance)
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            }
          }
          .padding(.trailing, 8)
          CircleSelected(isSelected: selectedAsset == asset.type)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
      }
    }
  }
}
