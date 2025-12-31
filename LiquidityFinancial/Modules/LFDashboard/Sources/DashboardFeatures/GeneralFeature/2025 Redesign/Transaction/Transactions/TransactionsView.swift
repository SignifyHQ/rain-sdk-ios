import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services

public struct TransactionsView: View {
  @StateObject private var viewModel: TransactionsViewModel
  @StateObject var transactionFilterViewModel: TransactionsFilterViewModel = TransactionsFilterViewModel()

  public init(
    currencyType: String,
    contractAddress: String? = nil,
    cardID: String? = nil,
    transactionTypes: [String] = []
  ) {
    _viewModel = .init(
      wrappedValue: .init(
        currencyType: currencyType,
        contractAddress: contractAddress,
        cardID: cardID ?? .empty,
        transactionTypes: transactionTypes
      )
    )
  }
  
  public var body: some View {
    VStack {
      if viewModel.isLoading {
        loadingView
      } else {
        contentView
      }
    }
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: L10N.Common.Transactions.Screen.title)
    .sheetWithContentHeight(
      isPresented: Binding(
        get: { viewModel.presentedFilterSheet != nil },
        set: { newValue in
          if !newValue {
            viewModel.presentedFilterSheet = nil
          }
        }
      )
    ) {
      TransactionsFilterSheetView(
        viewModel: transactionFilterViewModel,
        presentedFilterSheet: $viewModel.presentedFilterSheet
      )
      .onAppear(
        perform: {
          transactionFilterViewModel.filterConfiguration = viewModel.filterConfiguration
        }
      )
    }
    .navigationLink(item: $viewModel.transactionDetail) { item in
      TransactionDetailsView(
        method: .transactionID(item.id),
        kind: item.detailType,
        isPopToRoot: false
      )
    }
    .onChange(
      of: transactionFilterViewModel.didApplyChanges
    ) { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        viewModel.filterConfiguration = transactionFilterViewModel.filterConfiguration
        viewModel.loadInitialData()
      }
    }
    .track(name: String(describing: type(of: self)))
  }
}

extension TransactionsView {
  var contentView: some View {
    VStack(spacing: 24) {
      DefaultSearchBar(searchText: $viewModel.searchText)
      
      HStack {
        ForEach(TransactionsFilterButtonType.allCases) { type in
          filterButton(type: type)
        }
        
        Spacer()
      }
      
      //showPurchasedCurrencyView
      
      listView
    }
  }
  
  var listView: some View {
    ScrollView(showsIndicators: false) {
      LazyVStack {
        ForEach($viewModel.filteredTransactions, id: \.id) { $monthSection in
          Section(
            header: headerSectionView(section: monthSection)
              .onTapGesture {
                withAnimation {
                  monthSection.isExpanded.toggle()
                  viewModel.expandedSections[monthSection.month] = monthSection.isExpanded
                }
              }
          ) {
            if monthSection.isExpanded {
              ForEach(monthSection.items) { transaction in
                TransactionItemView(transaction: transaction) {
                  viewModel.selectedTransaction(transaction)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .listRowBackground(Colors.background.swiftUIColor)
                .onAppear {
                  viewModel.loadMoreIfNeccessary(transaction: transaction)
                }
              }
            }
          }
        }
      }
      
      if viewModel.isLoadingMore {
        DefaultLottieView(loading: .ctaFast)
          .frame(width: 24, height: 24)
      }
    }
  }
  
  func headerSectionView(section: TransactionSection) -> some View {
    VStack(spacing: 12) {
      HStack {
        Text(section.month)
          .foregroundColor(Colors.textTertiary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .frame(maxWidth: .infinity, alignment: .leading)
        
        (section.isExpanded ? GenImages.Images.icoExpandDown.swiftUIImage : GenImages.Images.icoExpandUp.swiftUIImage)
          .resizable()
          .frame(width: 24, height: 24)
      }
      .padding(.horizontal, 8)
      
      Divider()
        .frame(height: 1)
        .background(Colors.greyDefault.swiftUIColor)
        .frame(maxWidth: .infinity)
    }
  }
  
  func filterButton(
    type: TransactionsFilterButtonType
  ) -> some View {
    Button(
      action: {
        viewModel.presentedFilterSheet = type
      }, label: {
        if let image = type.image {
          image
        }
        
        if let title = type.title {
          HStack(spacing: 4) {
            if let appliedFiltersCount = viewModel.appliedFilters[type],
               appliedFiltersCount > 0 {
              Text("\(title) (\(appliedFiltersCount))")
            } else {
              Text(title)
            }
            
            GenImages.Images.icoExpandDown.swiftUIImage
              .resizable()
              .frame(width: 16, height: 16)
          }
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        }
      }
    )
    .frame(height: 32, alignment: .center)
    .padding(.horizontal, 12)
    .background(Colors.buttonSurfaceSecondary.swiftUIColor)
    .foregroundColor(Colors.textPrimary.swiftUIColor)
    .cornerRadius(16)
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(Colors.greyDefault.swiftUIColor, lineWidth: 1)
    }
  }
  
  var showPurchasedCurrencyView: some View {
    Toggle(isOn: $viewModel.isShowingPurchasedCurrency) {
      Text(L10N.Common.Transactions.ShowPurchasedCurrency.title)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, 16)
  }
  
  var loadingView: some View {
    VStack(alignment: .center) {
      Spacer()
      DefaultLottieView(loading: .branded)
        .frame(width: 52, height: 52)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
}
