import SwiftUI
import NetSpendData
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct ConnectedAccountsView: View {
  @StateObject private var viewModel: ConnectedAccountsViewModel
  
  public init(linkedAccount: [APILinkedSourceData]) {
    _viewModel = .init(
      wrappedValue: ConnectedAccountsViewModel(linkedAccount: linkedAccount)
    )
  }
  
  public var body: some View {
    content
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(L10N.Common.ConnectedView.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewModel.addBankWithDebit()
          } label: {
            CircleButton(style: .plus)
          }
        }
      }
      .background(Colors.background.swiftUIColor)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .addBankWithDebit:
          AddBankWithDebitView()
        case .verifyAccount(let id):
          VerifyCardView(cardId: id)
        }
      }
      .popup(item: $viewModel.popup) { item in
        switch item {
        case let .delete(data):
          deletePopup(linkedSource: data)
        }
      }
      .onAppear {
        viewModel.trackAccountViewAppear()
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
        ConnectedAccountRow(sourceData: item) {
          viewModel.verify(sourceData: item)
        } deleteAction: {
          viewModel.openDeletePopup(linkedSource: item)
        }
      }
    }
  }
  
  func deletePopup(linkedSource: APILinkedSourceData) -> some View {
    LiquidityAlert(
      title: L10N.Common.ConnectedView.DeletePopup.title.uppercased(),
      message: L10N.Common.ConnectedView.DeletePopup.message,
      primary: .init(text: L10N.Common.ConnectedView.DeletePopup.primaryButton) {
        viewModel.deleteAccount(
          id: linkedSource.sourceId,
          sourceType: linkedSource.sourceType.rawValue
        )
      },
      secondary: .init(text: L10N.Common.Button.Back.title) {
        viewModel.hidePopup()
      },
      isLoading: $viewModel.isDeleting
    )
  }
}
