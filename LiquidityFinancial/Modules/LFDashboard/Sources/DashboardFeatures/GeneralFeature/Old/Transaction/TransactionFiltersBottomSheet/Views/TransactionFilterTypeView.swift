import LFLocalizable
import LFStyleGuide
import SwiftUI

struct TransactionFilterTypeView: View {
  @ObservedObject var viewModel: TransactionFilterViewModel
  @Environment(\.dismiss) var dismiss
  
  @Binding var presentedFilterSheet: TransactionFilterButtonType?
  var shouldShowBackButton: Bool = false
  
  var body: some View {
    VStack {
      header
        .padding(.bottom, 25)
      
      content
      
      Spacer()
      
      buttons
    }
    .toolbar(.hidden)
    .padding(.top, 25)
    .padding(.horizontal, 25)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Colors.bottomSheetBackground.swiftUIColor)
  }
  
  private var header: some View {
    ZStack {
      HStack {
        Spacer()
        
        Text(L10N.Common.TransactionFilters.TypeFilter.title)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .center)
        
        Spacer()
      }
      
      if shouldShowBackButton {
        HStack {
          Button(
            action: {
              dismiss()
            }
          ) {
            Image(systemName: "arrow.left")
              .font(.title2)
              .foregroundColor(.primary)
          }
          
          Spacer()
        }
      }
    }
  }
  
  private var content: some View {
    VStack(
      spacing: 25
    ) {
      ForEach(FilterTransactionType.allCases) { type in
        Button {
          viewModel.toggle(filter: type)
        } label: {
          HStack {
            type.image
            
            Text(type.title)
              .font(Fonts.regular.swiftUIFont(size: 16))
              .foregroundColor(Colors.label.swiftUIColor)
            
            Spacer()
            
            if viewModel.filterConfiguration.selectedTypes.contains(type) {
              GenImages.CommonImages.icCheckmarkBig.swiftUIImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15)
            }
          }
        }
      }
    }
  }
  
  private var buttons: some View {
    HStack(
      spacing: 4
    ) {
      FullSizeButton(
        title: L10N.Common.TransactionFilters.Buttons.Reset.title,
        isDisable: false,
        type: .alternative
      ) {
        viewModel.filterConfiguration.selectedTypes.removeAll()
      }
      
      Spacer()
      
      FullSizeButton(
        title: L10N.Common.TransactionFilters.Buttons.Apply.title,
        isDisable: false,
        type: .tertiary
      ) {
        viewModel.apply()
        presentedFilterSheet = nil
      }
    }
  }
}
