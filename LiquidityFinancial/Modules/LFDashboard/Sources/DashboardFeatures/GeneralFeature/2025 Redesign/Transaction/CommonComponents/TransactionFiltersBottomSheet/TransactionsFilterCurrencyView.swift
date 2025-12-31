import LFLocalizable
import LFStyleGuide
import SwiftUI
import LFUtilities

struct TransactionsFilterCurrencyView: View {
  @ObservedObject var viewModel: TransactionsFilterViewModel
  
  var body: some View {
    contentView
      .frame(maxWidth: .infinity)
      .background(Colors.grey900.swiftUIColor)
  }
}

extension TransactionsFilterCurrencyView {
  var contentView: some View {
    VStack(spacing: 24) {
      ForEach(viewModel.assetModelList) { asset in
        Button {
          viewModel.toggle(filter: asset)
        } label: {
          HStack {
            asset.type?.icon
            
            Text(asset.type?.symbol ?? "N/A")
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(Colors.textPrimary.swiftUIColor)
            
            Spacer()
            
            if viewModel.filterConfiguration.selectedCurrencies.contains(asset) {
              GenImages.Images.icoCheck.swiftUIImage
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
            }
          }
        }
      }
    }
  }
}
