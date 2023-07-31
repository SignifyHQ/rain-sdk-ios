import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct TransactionListView: View {
  @StateObject private var viewModel: TransactionListViewModel

  init(type: TransactionListViewModel.Kind) {
    _viewModel = .init(wrappedValue: .init(type: type))
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
  }

  private var content: some View {
    Group {
      if viewModel.showIndicator {
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
