import Foundation
import LFLocalizable
import LFStyleGuide
import SwiftUI
import LFUtilities

public struct TransactionsFilterSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var contentHeight: CGFloat = 500
  @ObservedObject var viewModel: TransactionsFilterViewModel
  
  @Binding var presentedFilterSheet: TransactionsFilterButtonType?
  
  public init(
    viewModel: TransactionsFilterViewModel,
    presentedFilterSheet: Binding<TransactionsFilterButtonType?>
  ) {
    self.viewModel = viewModel
    _presentedFilterSheet = presentedFilterSheet
  }
  
  public var body: some View {
    mainContentView()
  }
}

extension TransactionsFilterSheetView {
  var headerView: some View {
    ZStack(alignment: .center) {
      Text(title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .center)
      
      HStack {
        if presentedFilterSheet != .all {
          Button(
            action: {
              withAnimation {
                presentedFilterSheet = .all
              }
            }
          ) {
            Image(systemName: "arrow.left")
              .font(.title2)
              .foregroundColor(Colors.iconPrimary.swiftUIColor)
          }
        }
        
        Spacer()
        
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .resizable()
            .frame(width: 14, height: 14, alignment: .center)
            .foregroundColor(Colors.iconPrimary.swiftUIColor)
        }
        .frame(width: 24, height: 24, alignment: .center)
      }
    }
  }
  
  var title: String {
    switch presentedFilterSheet {
    case .all:
      L10N.Common.Transactions.Filters.All.title
    case .type:
      L10N.Common.Transactions.Filters.TypeFilter.title
    case .currency:
      L10N.Common.Transactions.Filters.CurrencyFilter.title
    default:
      L10N.Common.Transactions.Filters.All.title
    }
  }
  
  @ViewBuilder
  var contentView: some View {
    VStack {
      switch presentedFilterSheet {
      case .all:
        VStack(spacing: 24) {
          typeItem
          currencyItem
        }
        
      case .type:
        TransactionsFilterTypeView(
          viewModel: viewModel
        )
        
      case .currency:
        TransactionsFilterCurrencyView(
          viewModel: viewModel
        )
        
      default:
        EmptyView()
      }
    }
    .animation(.easeInOut(duration: 0.3), value: presentedFilterSheet)
  }
  
  var typeItem: some View {
    Button {
      withAnimation(.bouncy) {
        presentedFilterSheet = .type
      }
    } label: {
      HStack(alignment: .top) {
        VStack(
          alignment: .leading,
          spacing: 2
        ) {
          Text(L10N.Common.Transactions.Filters.TypeFilter.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
          
          if !viewModel.filterConfiguration.selectedTypes.isEmpty {
            Text(
              viewModel.filterConfiguration.selectedTypes
                .map { type in
                  type.title
                }
                .joined(separator: ", ")
            )
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.grey50.swiftUIColor)
          }
        }
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.body)
          .foregroundStyle(Colors.iconPrimary.swiftUIColor)
      }
      .frame(height: 42)
    }
    .frame(maxWidth: .infinity)
  }
  
  var currencyItem: some View {
    Button {
      withAnimation {
        presentedFilterSheet = .currency
      }
    } label: {
      HStack {
        VStack(
          alignment: .leading,
          spacing: 2
        ) {
          Text(L10N.Common.Transactions.Filters.CurrencyFilter.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
          
          if !viewModel.filterConfiguration.selectedCurrencies.isEmpty {
            Text(
              viewModel.filterConfiguration.selectedCurrencies
                .map { asset in
                  asset.type?.symbol ?? "N/A"
                }
                .joined(separator: ", ")
            )
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.grey50.swiftUIColor)
          }
        }
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.body)
          .foregroundStyle(Colors.iconPrimary.swiftUIColor)
      }
    }
    .frame(maxWidth: .infinity)
  }
  
  var buttonsView: some View {
    let isAllSheet = presentedFilterSheet == .all
    
    return HStack(spacing: 16) {
      FullWidthButton(
        backgroundColor: Colors.grey400.swiftUIColor,
        title: isAllSheet ? L10N.Common.Transactions.Filters.Buttons.ResetAllFilters.title : L10N.Common.Transactions.Filters.Buttons.ResetAll.title
      ) {
        switch presentedFilterSheet {
        case .all:
          viewModel.resetAll()
        case .type:
          viewModel.resetType()
        case .currency:
          viewModel.resetCurrency()
        default:
          break
        }
      }
      
      if !isAllSheet {
        FullWidthButton(
          backgroundColor: Colors.buttonSurfacePrimary.swiftUIColor,
          title: L10N.Common.Transactions.Filters.Buttons.Apply.title
        ) {
          viewModel.apply()
          presentedFilterSheet = nil
        }
      }
    }
  }
  
  func mainContentView() -> some View {
    VStack(spacing: 32) {
      headerView
      contentView
      buttonsView
    }
    .toolbar(.hidden)
    .padding(.top, 24)
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity)
    .background(Colors.grey900.swiftUIColor)
    .readGeometry { proxy in
      let measuredHeight = proxy.size.height
      if measuredHeight > 0 {
        contentHeight = measuredHeight
      }
    }
    .frame(height: contentHeight)
  }
}
