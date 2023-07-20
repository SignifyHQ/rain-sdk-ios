import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct ChangeAssetView: View {
  @Binding var selectedAsset: AssetType
  let balance: Double
  let assets: [AssetType]

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(LFLocalizable.ChangeAsset.Screen.message)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      VStack(spacing: 10) {
        ForEach(assets, id: \.self) { asset in
          assetCell(asset: asset)
        }
      }
      Spacer()
    }
    .padding(.top, 24)
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(LFLocalizable.ChangeAsset.Screen.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
    }
  }
}

// MARK: - View Components
private extension ChangeAssetView {
  func assetCell(asset: AssetType) -> some View {
    Button {
      selectedAsset = asset
    } label: {
      HStack(spacing: 8) {
        asset.image
        Text(asset.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        Spacer()
        VStack(alignment: .trailing, spacing: 2) {
          Text(asset.getBalance(balance: balance).0)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.Inter.black.swiftUIFont(size: Constants.FontSize.medium.value))
          if let bottomBalance = asset.getBalance(balance: balance).1 {
            Text(bottomBalance)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          }
        }
        .padding(.trailing, 8)
        CircleSelected(isSelected: selectedAsset == asset)
      }
      .padding(.horizontal, 16)
      .frame(height: 56)
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
    }
  }
}
