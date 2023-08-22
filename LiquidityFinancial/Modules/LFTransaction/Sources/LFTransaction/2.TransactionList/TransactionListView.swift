import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

public struct TransactionListView: View {
  @StateObject private var viewModel: TransactionListViewModel
  
  public init(type: TransactionListViewModel.Kind, currencyType: String, accountID: String?) {
    _viewModel = .init(wrappedValue: .init(type: type, currencyType: currencyType, accountID: accountID ?? .empty))
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
        Text(LFLocalizable.TransactionList.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
    .onAppear(perform: viewModel.onAppear)
    .navigationLink(item: $viewModel.transactionDetail) { item in
      TransactionDetailView(accountID: viewModel.accountID, transactionId: item.id, kind: item.detailType, isPopToRoot: false)
    }
  }
}

// MARK: - View Components
private extension TransactionListView {
  var content: some View {
    VStack(spacing: 10) {
      SearchBar(searchText: $viewModel.searchText)
        .padding(.bottom, 5)
      ScrollView {
        ForEach(viewModel.filteredTransactions) { transaction in
          TransactionRowView(item: transaction) {
            viewModel.selectedTransaction(transaction)
          }
          .onAppear {
            viewModel.loadMoreIfNeccessary(transaction: transaction)
          }
        }
      }
      if viewModel.isLoadingMore {
        LottieView(loading: .mix)
          .frame(width: 30, height: 20)
      }
    }
    .padding(.horizontal, 30)
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
