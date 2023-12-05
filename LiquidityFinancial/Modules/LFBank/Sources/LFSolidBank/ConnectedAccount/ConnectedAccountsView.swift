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
          trailingToolbarButton
        }
      }
      .background(Colors.background.swiftUIColor)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .addMoney:
          MoveMoneyAccountView(kind: .receive)
        }
      }
      .sheet(item: $viewModel.plaidConfig) { item in
        PlaidLinkView(configuration: item.config)
      }
      .popup(item: $viewModel.popup) { item in
        switch item {
        case let .delete(data):
          deletePopup(linkedSource: data)
        case .plaidLinkingError:
          plaidLinkingErrorPopup
        }
      }
      .disabled(viewModel.isDisableView)
      .onAppear {
        viewModel.trackAccountViewAppear()
      }
  }
}

 // MARK: - Private View Components
private extension ConnectedAccountsView {
  var content: some View {
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
  
  var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 30, height: 25)
        .padding(.top, 20)
    }
    .frame(maxWidth: .infinity)
  }
  
  var trailingToolbarButton: some View {
    ZStack {
      if viewModel.isLoadingLinkExternalBank {
        LottieView(loading: .primary)
          .frame(width: 30, height: 25)
      } else {
        Button {
          viewModel.linkExternalBank()
        } label: {
          CircleButton(style: .plus)
        }
      }
    }
  }

  var contacts: some View {
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
  
  var plaidLinkingErrorPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.PlaidLink.Popup.title,
      message: LFLocalizable.PlaidLink.Popup.description,
      primary: .init(
        text: LFLocalizable.PlaidLink.ContactSupport.title,
        action: {
          viewModel.plaidLinkingErrorPrimaryAction()
        }
      )
    )
  }
}
