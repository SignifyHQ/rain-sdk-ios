import Foundation
import LFLocalizable
import LFStyleGuide
import SwiftUI

public struct TransactionFilterSheetView: View {
  @ObservedObject var viewModel: TransactionFilterViewModel
  
  @Binding var presentedFilterSheet: TransactionFilterButtonType?
  
  public init(
    viewModel: TransactionFilterViewModel,
    presentedFilterSheet: Binding<TransactionFilterButtonType?>
  ) {
    self.viewModel = viewModel
    _presentedFilterSheet = presentedFilterSheet
  }
  
  public var body: some View {
    if presentedFilterSheet == .type {
      typeFilterView()
    } else if presentedFilterSheet == .currency {
      currencyFilterView()
    } else {
      navigationStackView()
    }
  }
    
  private var header: some View {
    HStack {
      Text(L10N.Common.TransactionFilters.AllFilters.title)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .center)
    }
  }
  
  private var content: some View {
    VStack(spacing: 25) {
      NavigationLink {
        typeFilterView(shouldShowBackButton: true)
      } label: {
        HStack {
          VStack(
            alignment: .leading,
            spacing: 2
          ) {
            Text(L10N.Common.TransactionFilters.TypeFilter.title)
              .font(Fonts.regular.swiftUIFont(size: 16))
              .foregroundColor(Colors.label.swiftUIColor)
            
            if !viewModel.filterConfiguration.selectedTypes.isEmpty {
              Text(
                viewModel.filterConfiguration.selectedTypes
                  .map { type in
                    type.title
                  }
                  .joined(separator: ", ")
              )
                .font(Fonts.regular.swiftUIFont(size: 12))
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            }
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .font(.body)
        }
      }
      
      NavigationLink {
        currencyFilterView(shouldShowBackButton: true)
      } label: {
        HStack {
          VStack(
            alignment: .leading,
            spacing: 2
          ) {
            Text(L10N.Common.TransactionFilters.CurrencyFilter.title)
              .font(Fonts.regular.swiftUIFont(size: 16))
              .foregroundColor(Colors.label.swiftUIColor)
            
            if !viewModel.filterConfiguration.selectedCurrencies.isEmpty {
              Text(
                viewModel.filterConfiguration.selectedCurrencies
                  .map { asset in
                    asset.type?.symbol ?? "N/A"
                  }
                  .joined(separator: ", ")
              )
                .font(Fonts.regular.swiftUIFont(size: 12))
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            }
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .font(.body)
        }
      }
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
  
  private var buttons: some View {
    HStack(spacing: 4) {
      FullSizeButton(
        title: L10N.Common.TransactionFilters.Buttons.Reset.title,
        isDisable: false,
        type: .alternative
      ) {
        viewModel.reset()
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
  
  private func typeFilterView(
    shouldShowBackButton: Bool = false
  ) -> some View {
    TransactionFilterTypeView(
      viewModel: viewModel,
      presentedFilterSheet: $presentedFilterSheet,
      shouldShowBackButton: shouldShowBackButton
    )
  }
  
  private func currencyFilterView(
    shouldShowBackButton: Bool = false
  ) -> some View {
    TransactionFilterCurrencyView(
      viewModel: viewModel,
      presentedFilterSheet: $presentedFilterSheet,
      shouldShowBackButton: shouldShowBackButton
    )
  }
  
  private func navigationStackView(
  ) -> some View {
    NavigationStack {
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
  }
}
