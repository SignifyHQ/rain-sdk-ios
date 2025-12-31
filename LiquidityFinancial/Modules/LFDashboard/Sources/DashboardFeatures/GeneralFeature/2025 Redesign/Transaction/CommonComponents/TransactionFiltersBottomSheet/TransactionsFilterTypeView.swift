import LFLocalizable
import LFStyleGuide
import SwiftUI
import LFUtilities

struct TransactionsFilterTypeView: View {
  @ObservedObject var viewModel: TransactionsFilterViewModel
  
  var body: some View {
    contentView
      .frame(maxWidth: .infinity)
      .background(Colors.grey900.swiftUIColor)
  }
}

extension TransactionsFilterTypeView {var contentView: some View {
    VStack(
      spacing: 24
    ) {
      ForEach(FilterTransactionType.allCases) { type in
        Button {
          viewModel.toggle(filter: type)
        } label: {
          HStack {
            type.image
            
            Text(type.title)
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(Colors.textPrimary.swiftUIColor)
            
            Spacer()
            
            if viewModel.filterConfiguration.selectedTypes.contains(type) {
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
