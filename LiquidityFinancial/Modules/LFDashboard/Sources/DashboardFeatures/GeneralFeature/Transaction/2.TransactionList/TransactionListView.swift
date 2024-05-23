import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services

public struct TransactionListView: View {
  @StateObject private var viewModel: TransactionListViewModel

  public init(
    filterType: TransactionListViewModel.FilterType,
    currencyType: String,
    contractAddress: String? = nil,
    cardID: String? = nil,
    transactionTypes: [String] = []
  ) {
    _viewModel = .init(
      wrappedValue: .init(
        filterType: filterType,
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
    .navigationLink(item: $viewModel.transactionDetail) { item in
      TransactionDetailView(
        method: .transactionID(item.id),
        kind: item.detailType,
        isPopToRoot: false
      )
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
