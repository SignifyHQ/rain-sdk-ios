import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import ExternalFundingData

public struct ConnectedAccountsView: View {
  @StateObject private var viewModel: ConnectedAccountsViewModel
  
  public init(linkedContacts: [LinkedSourceContact]) {
    _viewModel = .init(
      wrappedValue: ConnectedAccountsViewModel(linkedContacts: linkedContacts)
    )
  }
  
  public var body: some View {
    content
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(LFLocalizable.ConnectedView.title)
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
      ForEach(viewModel.linkedContacts, id: \.sourceId) { item in
        ConnectedAccountRow(sourceData: item) {
          viewModel.openDeletePopup(linkedSource: item)
        }
      }
    }
  }
  
  func deletePopup(linkedSource: LinkedSourceContact) -> some View {
    LiquidityAlert(
      title: LFLocalizable.ConnectedView.DeletePopup.title.uppercased(),
      message: LFLocalizable.ConnectedView.DeletePopup.message,
      primary: .init(text: LFLocalizable.ConnectedView.DeletePopup.primaryButton) {
        viewModel.deleteAccount(id: linkedSource.sourceId)
      },
      secondary: .init(text: LFLocalizable.Button.Back.title) {
        viewModel.hidePopup()
      },
      isLoading: $viewModel.isDeleting
    )
  }
}
