import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services

public struct TransactionListView: View {
  @StateObject private var viewModel: TransactionListViewModel
  @StateObject var transactionFilterViewModel: TransactionFilterViewModel = TransactionFilterViewModel()

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
    ZStack {
      if viewModel.isLoading {
        loading
      } else {
        content
      }
    }
    .background(Colors.background.swiftUIColor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(L10N.Common.TransactionList.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
    .sheet(
      item: $viewModel.presentedFilterSheet
    ) { _ in
      TransactionFilterSheetView(
        viewModel: transactionFilterViewModel,
        presentedFilterSheet: $viewModel.presentedFilterSheet
      )
      .presentationDetents([.height(310), .height(350)])
      .presentationDragIndicator(.hidden)
      .onAppear(
        perform: {
          transactionFilterViewModel.filterConfiguration = viewModel.filterConfiguration
        }
      )
    }
    .navigationLink(item: $viewModel.transactionDetail) { item in
      TransactionDetailView(
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

// MARK: - Private View Components
private extension TransactionListView {
  var content: some View {
    VStack(spacing: 10) {
      SearchBar(searchText: $viewModel.searchText)
        .padding(.bottom, 5)
      
      HStack {
        ForEach(TransactionFilterButtonType.allCases) { type in
          filterButton(type: type)
        }
        
        Spacer()
      }
      
      ScrollView(showsIndicators: false) {
        LazyVStack {
          ForEach(viewModel.filteredTransactions) { transaction in
            TransactionRowView(item: transaction) {
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
        .background(Color.clear)
        if viewModel.isLoadingMore {
          LottieView(loading: .mix)
            .frame(width: 30, height: 20)
        }
      }
      .background(Color.clear)
    }
    .background(Colors.background.swiftUIColor)
    .padding(.horizontal, 24)
  }
  
  func filterButton(
    type: TransactionFilterButtonType
  ) -> some View {
    Button(
      action: {
        viewModel.presentedFilterSheet = type
      }, label: {
        if let image = type.image {
          image
        }
        
        if let title = type.title {
          HStack {
            if let appliedFiltersCount = viewModel.appliedFilters[type],
               appliedFiltersCount > 0 {
              Text("\(title) (\(appliedFiltersCount))")
            } else {
              Text(title)
            }
            
            GenImages.CommonImages.icArrowDown.swiftUIImage
          }
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        }
      }
    )
    .frame(height: 40, alignment: .center)
    .padding(.horizontal, 8)
    .background(
      Colors.buttons.swiftUIColor
    )
    .foregroundColor(Colors.label.swiftUIColor)
    .cornerRadius(10)
  }
  
  var loading: some View {
    VStack {
      Spacer()
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
}
