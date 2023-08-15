import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct TransactionListView: View {
  @StateObject private var viewModel: TransactionListViewModel

  init(type: TransactionListViewModel.Kind, currencyType: String ) {
    _viewModel = .init(wrappedValue: .init(type: type, currencyType: currencyType))
  }

  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(LFLocalizable.TransactionList.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      .onAppear(perform: viewModel.onAppear)
      .sheet(item: $viewModel.transactionDetail) { item in
        TransactionDetailView(type: viewModel.rowType, transactionId: item.id ?? .empty)
          .embedInNavigation()
      }
  }

  private var content: some View {
    Group {
      if viewModel.isLoading {
        loading
      } else {
        VStack(spacing: 10) {
          SearchBar(searchText: $viewModel.searchText)
            .padding(.bottom, 5)
            .padding(.horizontal, 30)
          ScrollView {
            ForEach(viewModel.filteredTransactions) { transaction in
              item(transaction)
            }
          }
          if viewModel.isLoadingMore {
            TransactionRowLoadingView()
              .frame(height: 48)
              .padding(.horizontal, 30)
          }
        }
      }
    }
  }

  private var loading: some View {
    VStack {
      Spacer()
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }

  private func item(_ transaction: TransactionModel) -> some View {
    TransactionRowView(item: transaction, type: viewModel.rowType) {
      viewModel.selectedTransaction(transaction)
    }
    .padding(.horizontal, 30)
    .onAppear {
      viewModel.loadMoreIfNeccessary(transaction: transaction)
    }
  }
}
