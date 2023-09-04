import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import BaseDashboard

struct AssetsView: View {
  @StateObject private var viewModel: AssetsViewModel
  
  init(viewModel: AssetsViewModel) {
    self._viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    ZStack {
      if viewModel.isLoading {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else {
        VStack(spacing: 10) {
          ForEach(viewModel.assets, id: \.self) { asset in
            assetCell(asset: asset)
          }
          
          Spacer()
          
          Text(LFLocalizable.AssetView.disclosure)
            .font(Fonts.Inter.extraLight.swiftUIFont(size: 10))
            .foregroundColor(Colors.whiteText.swiftUIColor)
            .padding(.bottom, 8)
        }
      }
    }
    .padding(.top, 24)
    .padding(.horizontal, 30)
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case let .usd(asset):
        FiatAssetView(asset: asset)
      case let .crypto(asset):
        CryptoAssetView(asset: asset)
      }
    }
  }
}

// MARK: - View Components
private extension AssetsView {
  @ViewBuilder func assetCell(asset: AssetModel) -> some View {
    if let assetType = asset.type {
      Button {
        viewModel.onClickedAsset(asset: asset)
      } label: {
        HStack(spacing: 8) {
          assetType.image
          Text(assetType.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          Spacer()
          VStack(alignment: .trailing, spacing: 2) {
            if let bottomBalance = asset.availableUsdBalanceFormatted {
              Text(bottomBalance)
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.Inter.bold.swiftUIFont(size: Constants.FontSize.medium.value))
            }
            
            let font = asset.type == .usd ?
            Fonts.Inter.bold.swiftUIFont(size: Constants.FontSize.medium.value) :
            Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value)
            
            Text(asset.availableBalanceFormatted)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(font)
          }
          .padding(.trailing, 8)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
      }
    }
  }
}
