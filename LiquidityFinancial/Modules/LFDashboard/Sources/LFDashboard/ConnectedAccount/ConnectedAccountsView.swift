import SwiftUI
import NetSpendData
import LFStyleGuide
import LFUtilities
import LFLocalizable

struct ConnectedAccountsView: View {
  @StateObject private var viewModel: ConnectedAccountsViewModel
  @State private var showDebitView = false
  
  init(linkedAccount: [APILinkedSourceData]) {
    _viewModel = .init(
      wrappedValue: ConnectedAccountsViewModel(linkedAccount: linkedAccount)
    )
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(LFLocalizable.ConnectedView.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showDebitView = true
          } label: {
            CircleButton(style: .plus)
          }
        }
      }
      .background(Colors.background.swiftUIColor)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .navigationLink(isActive: $showDebitView) {
        AddBankWithDebitView()
      }
  }

  private var content: some View {
    VStack(spacing: 10) {
      if viewModel.isLoading {
        loading
      } else {
        contacts
      }
      Spacer()
        .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 20)
    .background(Colors.background.swiftUIColor)
  }
  
  private var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 30, height: 25)
        .padding(.top, 20)
    }
    .frame(maxWidth: .infinity)
  }

  private var contacts: some View {
    Group {
      ForEach(viewModel.linkedAccount, id: \.sourceId) { item in
        TitleRow(
          image: GenImages.CommonImages.Accounts.connectedAccounts,
          title: viewModel.title(for: item),
          style: .delete
        ) {
          viewModel.deleteAccount(id: item.sourceId)
        }
      }
    }
  }
}
